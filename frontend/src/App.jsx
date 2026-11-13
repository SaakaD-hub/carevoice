import { useEffect, useState } from 'react';

export default function App() {
  const [backend, setBackend] = useState('checking...');

  useEffect(() => {
    fetch('/api/ping')
      .then((r) => r.json())
      .then((d) => setBackend(`${d.status} (${d.time})`))
      .catch(() => setBackend('not reachable'));
  }, []);

  return (
    <main style={{ fontFamily: 'system-ui, sans-serif', maxWidth: 640, margin: '48px auto', padding: 16 }}>
      <h1>CareVoice</h1>
      <p>Helping home care aides speak up and making sure someone acts on it.</p>
      <p>
        <strong>Backend:</strong> {backend}
      </p>
    </main>
  );
}
