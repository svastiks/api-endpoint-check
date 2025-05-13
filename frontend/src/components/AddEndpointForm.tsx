import React, { useState } from "react";
import api from "../api/axios";
import { Endpoint } from "../types/endpoint";

interface AddEndpointFormProps {
  onSuccess: (endpoint: Endpoint) => void;
}

const AddEndpointForm: React.FC<AddEndpointFormProps> = ({ onSuccess }) => {
  const [url, setUrl] = useState("");
  const [name, setName] = useState("");
  const [checkInterval, setCheckInterval] = useState(60);
  const [notificationEmail, setNotificationEmail] = useState("");
  const [active, setActive] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const response = await api.post<{ data: Endpoint }>("/endpoints", {
        endpoint: {
          url,
          name,
          check_interval_seconds: checkInterval,
          notification_email: notificationEmail || null,
          active,
        },
      });
      onSuccess(response.data.data);
      setUrl("");
      setName("");
      setCheckInterval(60);
      setNotificationEmail("");
      setActive(true);
    } catch (err: any) {
      setError("Failed to add endpoint.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      style={{
        background: "#f8fafc",
        borderRadius: 12,
        boxShadow: "0 2px 12px rgba(0,0,0,0.06)",
        padding: "2rem 1.5rem 1.5rem 1.5rem",
        marginBottom: "2rem",
        minWidth: 0,
      }}
    >
      <div style={{ fontWeight: 700, fontSize: 22, marginBottom: 18, letterSpacing: -1 }}>Add New Endpoint</div>
      {error && <div style={{ color: "#f44336", marginBottom: 12 }}>{error}</div>}
      <div style={{ marginBottom: 16 }}>
        <label style={{ fontWeight: 500, display: "block", marginBottom: 4 }}>
          Name
          <input
            value={name}
            onChange={e => setName(e.target.value)}
            required
            style={{
              width: "100%",
              padding: "10px 12px",
              borderRadius: 6,
              border: "1px solid #ccc",
              fontSize: 16,
              marginTop: 4
            }}
          />
        </label>
      </div>
      <div style={{ marginBottom: 16 }}>
        <label style={{ fontWeight: 500, display: "block", marginBottom: 4 }}>
          URL
          <input
            value={url}
            onChange={e => setUrl(e.target.value)}
            required
            type="url"
            placeholder="https://example.com/health"
            style={{
              width: "100%",
              padding: "10px 12px",
              borderRadius: 6,
              border: "1px solid #ccc",
              fontSize: 16,
              marginTop: 4
            }}
          />
        </label>
      </div>
      <div style={{ marginBottom: 16 }}>
        <label style={{ fontWeight: 500, display: "block", marginBottom: 4 }}>
          Check Interval (seconds)
          <input
            type="number"
            value={checkInterval}
            onChange={e => setCheckInterval(Number(e.target.value))}
            min={10}
            required
            style={{
              width: "100%",
              padding: "10px 12px",
              borderRadius: 6,
              border: "1px solid #ccc",
              fontSize: 16,
              marginTop: 4
            }}
          />
        </label>
      </div>
      <div style={{ marginBottom: 16 }}>
        <label style={{ fontWeight: 500, display: "block", marginBottom: 4 }}>
          Notification Email
          <input
            type="email"
            value={notificationEmail}
            onChange={e => setNotificationEmail(e.target.value)}
            placeholder="optional"
            style={{
              width: "100%",
              padding: "10px 12px",
              borderRadius: 6,
              border: "1px solid #ccc",
              fontSize: 16,
              marginTop: 4
            }}
          />
        </label>
      </div>
      <div style={{ marginBottom: 18, display: "flex", alignItems: "center" }}>
        <label style={{ fontWeight: 500, marginRight: 10 }}>
          <input
            type="checkbox"
            checked={active}
            onChange={e => setActive(e.target.checked)}
            style={{ marginRight: 6 }}
          />
          Active
        </label>
      </div>
      <button
        type="submit"
        disabled={loading}
        style={{
          width: "100%",
          background: "#1976d2",
          color: "#fff",
          border: "none",
          borderRadius: 8,
          padding: "0.9rem 0",
          fontWeight: 700,
          fontSize: 17,
          letterSpacing: 0.5,
          cursor: loading ? "not-allowed" : "pointer",
          boxShadow: "0 1px 4px rgba(25, 118, 210, 0.08)"
        }}
      >
        {loading ? "Adding..." : "Add Endpoint"}
      </button>
    </form>
  );
};

export default AddEndpointForm;