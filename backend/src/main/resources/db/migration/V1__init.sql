-- Core tables. Extend in later migrations (V2__..., V3__...). Never edit a migration once merged.

CREATE TABLE client (
    id          BIGSERIAL PRIMARY KEY,
    full_name   VARCHAR(120) NOT NULL,
    family_lang VARCHAR(10)  NOT NULL DEFAULT 'en',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- M1 Discharge Baseline ------------------------------------------------------

CREATE TABLE discharge_plan (
    id            BIGSERIAL PRIMARY KEY,
    client_id     BIGINT       NOT NULL REFERENCES client(id),
    file_name     VARCHAR(255) NOT NULL,
    storage_key   VARCHAR(255) NOT NULL,          -- where the original PDF is kept (restricted access)
    discharged_on DATE,
    status        VARCHAR(20)  NOT NULL DEFAULT 'PENDING_REVIEW', -- PENDING_REVIEW, APPROVED
    approved_by   VARCHAR(120),
    approved_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE watch_item (
    id           BIGSERIAL PRIMARY KEY,
    plan_id      BIGINT       NOT NULL REFERENCES discharge_plan(id),
    item_type    VARCHAR(30)  NOT NULL,           -- MEDICATION, WARNING_SIGN, APPOINTMENT, ACTIVITY, DIET
    summary      TEXT         NOT NULL,           -- plain-language version
    source_quote TEXT         NOT NULL,           -- exact text from the PDF
    source_page  INT,
    status       VARCHAR(20)  NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED, EDITED
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE plan_gap (
    id          BIGSERIAL PRIMARY KEY,
    plan_id     BIGINT      NOT NULL REFERENCES discharge_plan(id),
    description TEXT        NOT NULL,             -- e.g. "Furosemide: no dose listed"
    resolved    BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- M2/M3 Visits and notes ------------------------------------------------------

CREATE TABLE visit (
    id           BIGSERIAL PRIMARY KEY,
    client_id    BIGINT       NOT NULL REFERENCES client(id),
    aide_name    VARCHAR(120) NOT NULL,
    visited_at   TIMESTAMPTZ  NOT NULL,
    spoken_lang  VARCHAR(10),
    transcript   TEXT,
    care_note    JSONB,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_visit_client_time ON visit (client_id, visited_at DESC);

-- M4 Risk flags / M5 Escalation ----------------------------------------------

CREATE TABLE risk_flag (
    id            BIGSERIAL PRIMARY KEY,
    client_id     BIGINT      NOT NULL REFERENCES client(id),
    visit_id      BIGINT      REFERENCES visit(id),
    watch_item_id BIGINT      REFERENCES watch_item(id),  -- set when the flag matches the discharge watch list
    rule_code     VARCHAR(50) NOT NULL,                    -- WATCH_LIST_MATCH, TREND_DECLINE, MISSED_MED
    severity      VARCHAR(10) NOT NULL,                    -- LOW, MEDIUM, HIGH
    reason        TEXT        NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE task (
    id          BIGSERIAL PRIMARY KEY,
    flag_id     BIGINT       NOT NULL REFERENCES risk_flag(id),
    owner       VARCHAR(120) NOT NULL,
    level       INT          NOT NULL DEFAULT 1,           -- escalation level
    due_at      TIMESTAMPTZ  NOT NULL,
    status      VARCHAR(20)  NOT NULL DEFAULT 'OPEN',      -- OPEN, ACKNOWLEDGED, RESOLVED
    outcome     TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE task_event (
    id          BIGSERIAL PRIMARY KEY,
    task_id     BIGINT       NOT NULL REFERENCES task(id),
    event_type  VARCHAR(20)  NOT NULL,                     -- CREATED, ACKNOWLEDGED, ESCALATED, RESOLVED
    actor       VARCHAR(120),
    note        TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_task_open_due ON task (status, due_at);

-- M6 Family Portal ------------------------------------------------------------

CREATE TABLE family_update (
    id          BIGSERIAL PRIMARY KEY,
    client_id   BIGINT      NOT NULL REFERENCES client(id),
    lang        VARCHAR(10) NOT NULL,
    body        TEXT        NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
