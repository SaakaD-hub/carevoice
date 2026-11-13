#!/usr/bin/env python3
"""
Generates a SYNTHETIC hospital discharge PDF for demos and tests.
Every person, hospital and detail here is made up.

Usage:  pip install reportlab
        python3 scripts/make_synthetic_discharge.py data/synthetic/discharge/johnson_discharge.pdf
"""
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak

OUT = sys.argv[1] if len(sys.argv) > 1 else "johnson_discharge.pdf"


def watermark(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica-Bold", 44)
    canvas.setFillColor(colors.Color(0.85, 0.1, 0.1, alpha=0.12))
    canvas.translate(4.25 * inch, 5.5 * inch)
    canvas.rotate(35)
    canvas.drawCentredString(0, 0, "SYNTHETIC - FOR TESTING")
    canvas.restoreState()
    canvas.setFont("Helvetica", 8)
    canvas.drawString(0.75 * inch, 0.5 * inch,
                      "Fictional document created for the CareVoice prototype. Not a real patient or hospital.")
    canvas.drawRightString(7.75 * inch, 0.5 * inch, f"Page {doc.page}")


styles = getSampleStyleSheet()
h = styles["Heading2"]
body = ParagraphStyle("body", parent=styles["BodyText"], fontSize=10.5, leading=14)

story = [
    Paragraph("Lakeview General Hospital (fictional)", styles["Title"]),
    Paragraph("Patient Discharge Instructions", styles["Heading1"]),
    Table([
        ["Patient:", "Margaret Johnson (fictional)", "DOB:", "03/14/1943"],
        ["Admitted:", "11/02/2026", "Discharged:", "11/07/2026"],
        ["Diagnosis:", "Heart failure exacerbation", "Attending:", "Dr. A. Rivera (fictional)"],
    ], colWidths=[0.9 * inch, 2.4 * inch, 0.9 * inch, 2.3 * inch],
        style=TableStyle([("FONT", (0, 0), (-1, -1), "Helvetica", 10),
                          ("FONT", (0, 0), (0, -1), "Helvetica-Bold", 10),
                          ("FONT", (2, 0), (2, -1), "Helvetica-Bold", 10),
                          ("BOTTOMPADDING", (0, 0), (-1, -1), 4)])),
    Spacer(1, 12),

    Paragraph("Why you were in the hospital", h),
    Paragraph("You were treated for fluid build-up caused by heart failure. Your breathing and swelling "
              "improved with medication. You are now safe to go home with daily support from a home care aide.",
              body),

    Paragraph("Your medications", h),
    Table([
        ["Medication", "Dose", "How often", "Notes"],
        ["Furosemide (water pill)", "", "Every morning", "Take with breakfast"],
        ["Lisinopril", "10 mg", "Once daily", "For blood pressure and heart"],
        ["Metoprolol succinate", "25 mg", "Once daily", "Do not stop suddenly"],
        ["Potassium chloride", "20 mEq", "Once daily", "Take with food"],
    ], colWidths=[1.9 * inch, 0.8 * inch, 1.2 * inch, 2.6 * inch],
        style=TableStyle([("FONT", (0, 0), (-1, 0), "Helvetica-Bold", 10),
                          ("FONT", (0, 1), (-1, -1), "Helvetica", 10),
                          ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
                          ("BACKGROUND", (0, 0), (-1, 0), colors.whitesmoke)])),
    Spacer(1, 6),
    Paragraph("Stop taking ibuprofen (Advil, Motrin). It can make heart failure worse.", body),

    PageBreak(),
    Paragraph("Warning signs: call your doctor", h),
    Paragraph("Weigh yourself every morning after using the bathroom and before breakfast. Write it down.", body),
    Paragraph("Call your doctor if you gain more than 3 lbs in 2 days or 5 lbs in a week.", body),
    Paragraph("Call your doctor if you notice swelling in your legs or ankles.", body),
    Paragraph("Call your doctor if you feel more short of breath than usual, or need more pillows to sleep.",
              body),
    Paragraph("Call your doctor if you feel dizzy or lightheaded when standing up.", body),
    Spacer(1, 6),
    Paragraph("<b>Call 911</b> if you have chest pain, severe trouble breathing, or fainting.", body),

    Paragraph("Diet and activity", h),
    Paragraph("Limit salt to 2,000 mg per day. Limit fluids to about 2 liters (8 cups) per day.", body),
    Paragraph("Walk short distances several times a day. No lifting over 10 lbs for 2 weeks.", body),

    Paragraph("Follow-up appointments", h),
    Paragraph("See your primary care doctor within 7 days of discharge.", body),
    Paragraph("Cardiology clinic: 11/20/2026 at 10:30 AM, Lakeview Heart Center (fictional).", body),
    Paragraph("Lab work (blood test for kidney function and potassium) before your cardiology visit.", body),
]

SimpleDocTemplate(OUT, pagesize=letter, leftMargin=0.75 * inch, rightMargin=0.75 * inch,
                  topMargin=0.75 * inch, bottomMargin=0.8 * inch).build(
    story, onFirstPage=watermark, onLaterPages=watermark)
print(f"wrote {OUT}")
