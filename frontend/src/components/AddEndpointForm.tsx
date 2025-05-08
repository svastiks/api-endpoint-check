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
    <form onSubmit={handleSubmit} style={{ marginBottom: "2rem" }}>
      <h3>Add New Endpoint</h3>
      {error && <div style={{ color: "red" }}>{error}</div>}
      <div>
        <label>
          Name:{" "}
          <input value={name} onChange={e => setName(e.target.value)} required />
        </label>
      </div>
      <div>
        <label>
          URL:{" "}
          <input
            value={url}
            onChange={e => setUrl(e.target.value)}
            required
            type="url"
            placeholder="https://example.com/health"
          />
        </label>
      </div>
      <div>
        <label>
          Check Interval (seconds):{" "}
          <input
            type="number"
            value={checkInterval}
            onChange={e => setCheckInterval(Number(e.target.value))}
            min={10}
            required
          />
        </label>
      </div>
      <div>
        <label>
          Notification Email:{" "}
          <input
            type="email"
            value={notificationEmail}
            onChange={e => setNotificationEmail(e.target.value)}
            placeholder="optional"
          />
        </label>
      </div>
      <div>
        <label>
          Active:{" "}
          <input
            type="checkbox"
            checked={active}
            onChange={e => setActive(e.target.checked)}
          />
        </label>
      </div>
      <button type="submit" disabled={loading}>
        {loading ? "Adding..." : "Add Endpoint"}
      </button>
    </form>
  );
};

export default AddEndpointForm;