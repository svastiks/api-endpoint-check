import React, { useEffect, useState } from "react";
import api from "../api/axios";
import { Endpoint, CheckResult } from "../types/endpoint";
import { fetchLatestCheckResult } from "../api/endpoints";

const EndpointList: React.FC = () => {
  const [endpoints, setEndpoints] = useState<Endpoint[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [latestResults, setLatestResults] = useState<Record<number, CheckResult | null>>({});
  const [expandedId, setExpandedId] = useState<number | null>(null);
  const [history, setHistory] = useState<Record<number, CheckResult[]>>({});
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editForm, setEditForm] = useState<Partial<Endpoint>>({});

  useEffect(() => {
    const fetchEndpoints = async () => {
      try {
        setLoading(true);
        const response = await api.get<{ data: Endpoint[] }>("/endpoints");
        setEndpoints(response.data.data);
      } catch (err) {
        setError("Failed to load endpoints.");
      } finally {
        setLoading(false);
      }
    };
    fetchEndpoints();
  }, []);

  // Update latest results when endpoints change
  useEffect(() => {
    if (endpoints.length === 0) return;
    const fetchAllLatest = async () => {
      const results: Record<number, CheckResult | null> = {};
      for (const ep of endpoints) {
        results[ep.id] = await fetchLatestCheckResult(ep.id);
      }
      setLatestResults(results);
    };
    fetchAllLatest();
  }, [endpoints]);

  // Update history when expanded endpoint changes
  useEffect(() => {
    if (expandedId === null) return;
    const fetchHistory = async () => {
      try {
        const response = await api.get<{ data: CheckResult[] }>(`/check_results/${expandedId}`);
        setHistory((prev) => ({ ...prev, [expandedId]: response.data.data }));
      } catch {
        setHistory((prev) => ({ ...prev, [expandedId]: [] }));
      }
    };
    fetchHistory();
  }, [expandedId]);

  const handleEditSubmit = async (e: React.FormEvent, id: number) => {
    e.preventDefault();
    try {
      await api.put(`/endpoints/${id}`, { endpoint: editForm });
      setEditingId(null);
      setEditForm({});
      // Refresh the list and latest results
      const response = await api.get<{ data: Endpoint[] }>("/endpoints");
      setEndpoints(response.data.data);
      const latest = await fetchLatestCheckResult(id);
      setLatestResults(prev => ({ ...prev, [id]: latest }));
    } catch {
      alert("Failed to update endpoint.");
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm("Are you sure you want to delete this endpoint?")) return;
    try {
      await api.delete(`/endpoints/${id}`);
      setEndpoints((prev) => prev.filter((ep) => ep.id !== id));
      setLatestResults(prev => {
        const { [id]: _, ...rest } = prev;
        return rest;
      });
    } catch {
      alert("Failed to delete endpoint.");
    }
  };

  if (loading) return <div>Loading endpoints...</div>;
  if (error) return <div style={{ color: "red" }}>{error}</div>;
  if (endpoints.length === 0) return <div>No endpoints configured yet.</div>;

  return (
    <div>
      <h2 style={{ fontWeight: 700, fontSize: 24, marginBottom: 24, letterSpacing: -1 }}>Your Endpoints</h2>
      <ul style={{ listStyle: "none", padding: 0, margin: 0 }}>
        {endpoints.map((ep) => {
          const latest = latestResults[ep.id];
          let statusColor = "#ccc";
          let statusText = "No Data";
          if (latest) {
            if (latest.status_code >= 200 && latest.status_code < 300) {
              statusColor = "#4caf50";
              statusText = latest.status_code.toString();
            } else if (latest.status_code >= 400 && latest.status_code < 500) {
              statusColor = "#ff9800";
              statusText = latest.status_code.toString();
            } else if (latest.status_code >= 500) {
              statusColor = "#f44336";
              statusText = latest.status_code.toString();
            } else {
              statusColor = "#aaa";
              statusText = latest.status_code.toString();
            }
          }

          return (
            <li
              key={ep.id}
              style={{
                border: "none",
                borderRadius: "14px",
                margin: "1.5rem 0",
                padding: 0,
                background: "none",
                boxShadow: "none"
              }}
            >
              <div style={{
                background: "#f8fafc",
                borderRadius: 14,
                boxShadow: "0 2px 12px rgba(0,0,0,0.06)",
                padding: "1.5rem 1.5rem 1rem 1.5rem",
                display: "flex",
                flexDirection: "column",
                gap: 8,
                transition: "box-shadow 0.2s",
                position: "relative",
                minWidth: 0,
                border: "1px solid #e3e8ee"
              }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div>
                    <div style={{ fontWeight: 600, fontSize: 18 }}>{ep.name || ep.url}</div>
                    <div style={{ fontSize: "0.97em", color: "#666", marginTop: 2 }}>{ep.url}</div>
                    <div style={{ fontSize: "0.93em", color: "#888", marginTop: 2 }}>
                      Email: {ep.notification_email || "—"}
                    </div>
                  </div>
                  <div>
                    <span
                      style={{
                        display: "inline-block",
                        minWidth: 48,
                        textAlign: "center",
                        padding: "0.4em 1.1em",
                        borderRadius: "1.2em",
                        background: statusColor,
                        color: "#fff",
                        fontWeight: 700,
                        fontSize: 18,
                        boxShadow: "0 1px 4px rgba(0,0,0,0.07)"
                      }}
                    >
                      {statusText}
                    </span>
                  </div>
                </div>
                <div style={{ fontSize: "0.89em", color: "#aaa", marginTop: "0.5em" }}>
                  Last checked: {latest && latest.checked_at ? new Date(latest.checked_at).toLocaleString() : "—"}
                </div>
                <div style={{ marginTop: "0.7em", display: "flex", gap: "0.7em" }}>
                  <button
                    onClick={() => {
                      setEditingId(ep.id);
                      setEditForm(ep);
                    }}
                    style={{
                      background: "#fff",
                      border: "1px solid #1976d2",
                      color: "#1976d2",
                      borderRadius: 6,
                      padding: "0.4em 1.1em",
                      fontWeight: 600,
                      fontSize: 15,
                      cursor: "pointer",
                      transition: "background 0.15s, color 0.15s"
                    }}
                  >
                    Edit
                  </button>
                  <button
                    style={{
                      color: "#fff",
                      background: "#f44336",
                      border: "none",
                      borderRadius: 6,
                      padding: "0.4em 1.1em",
                      fontWeight: 600,
                      fontSize: 15,
                      cursor: "pointer"
                    }}
                    onClick={() => handleDelete(ep.id)}
                  >
                    Delete
                  </button>
                  <button
                    style={{
                      marginLeft: "auto",
                      background: "#1976d2",
                      color: "#fff",
                      border: "none",
                      borderRadius: 6,
                      padding: "0.4em 1.1em",
                      fontWeight: 600,
                      fontSize: 15,
                      cursor: "pointer"
                    }}
                    onClick={() => setExpandedId(expandedId === ep.id ? null : ep.id)}
                  >
                    {expandedId === ep.id ? "Hide History" : "Show History"}
                  </button>
                </div>
                {editingId === ep.id && (
                  <form
                    style={{
                      marginTop: "1em",
                      background: "#f9f9f9",
                      padding: "1em",
                      borderRadius: 8,
                      boxShadow: "0 1px 4px rgba(0,0,0,0.04)",
                      border: "1px solid #e3e8ee"
                    }}
                    onSubmit={e => handleEditSubmit(e, ep.id)}
                  >
                    <div style={{ marginBottom: 10 }}>
                      <label style={{ fontWeight: 500 }}>
                        Name
                        <input
                          value={editForm.name ?? ep.name}
                          onChange={e => setEditForm(f => ({ ...f, name: e.target.value }))}
                          style={{
                            width: "100%",
                            padding: "8px 10px",
                            borderRadius: 6,
                            border: "1px solid #ccc",
                            fontSize: 15,
                            marginTop: 4
                          }}
                        />
                      </label>
                    </div>
                    <div style={{ marginBottom: 10 }}>
                      <label style={{ fontWeight: 500 }}>
                        URL
                        <input
                          value={editForm.url ?? ep.url}
                          onChange={e => setEditForm(f => ({ ...f, url: e.target.value }))}
                          style={{
                            width: "100%",
                            padding: "8px 10px",
                            borderRadius: 6,
                            border: "1px solid #ccc",
                            fontSize: 15,
                            marginTop: 4
                          }}
                        />
                      </label>
                    </div>
                    <div style={{ marginBottom: 10 }}>
                      <label style={{ fontWeight: 500 }}>
                        Check Interval (seconds)
                        <input
                          type="number"
                          value={editForm.check_interval_seconds ?? ep.check_interval_seconds}
                          onChange={e => setEditForm(f => ({ ...f, check_interval_seconds: Number(e.target.value) }))}
                          style={{
                            width: "100%",
                            padding: "8px 10px",
                            borderRadius: 6,
                            border: "1px solid #ccc",
                            fontSize: 15,
                            marginTop: 4
                          }}
                        />
                      </label>
                    </div>
                    <div style={{ marginBottom: 10 }}>
                      <label style={{ fontWeight: 500 }}>
                        Notification Email
                        <input
                          type="email"
                          value={editForm.notification_email ?? ep.notification_email ?? ""}
                          onChange={e => setEditForm(f => ({ ...f, notification_email: e.target.value }))}
                          style={{
                            width: "100%",
                            padding: "8px 10px",
                            borderRadius: 6,
                            border: "1px solid #ccc",
                            fontSize: 15,
                            marginTop: 4
                          }}
                        />
                      </label>
                    </div>
                    <div style={{ marginBottom: 10, display: "flex", alignItems: "center" }}>
                      <label style={{ fontWeight: 500, marginRight: 10 }}>
                        <input
                          type="checkbox"
                          checked={editForm.active ?? ep.active}
                          onChange={e => setEditForm(f => ({ ...f, active: e.target.checked }))}
                          style={{ marginRight: 6 }}
                        />
                        Active
                      </label>
                    </div>
                    <button
                      type="submit"
                      style={{
                        width: "100%",
                        background: "#1976d2",
                        color: "#fff",
                        border: "none",
                        borderRadius: 8,
                        padding: "0.7rem 0",
                        fontWeight: 700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        cursor: "pointer"
                      }}
                    >
                      Save
                    </button>
                  </form>
                )}
                {expandedId === ep.id && (
                  <div style={{
                    marginTop: "1em",
                    background: "#f9f9f9",
                    padding: "1em",
                    borderRadius: 8,
                    boxShadow: "0 1px 4px rgba(0,0,0,0.04)",
                    border: "1px solid #e3e8ee",
                    maxHeight: "300px",
                    overflowY: "auto"
                  }}>
                    <h3 style={{ margin: "0 0 1em 0", fontSize: "1.1em", fontWeight: 600 }}>Check History</h3>
                    {history[ep.id] && history[ep.id].length > 0 ? (
                      <div style={{ display: "flex", flexDirection: "column", gap: "0.8em" }}>
                        {history[ep.id].map((result) => {
                          let statusColor = "#ccc";
                          if (result.status_code >= 200 && result.status_code < 300) {
                            statusColor = "#4caf50";
                          } else if (result.status_code >= 400 && result.status_code < 500) {
                            statusColor = "#ff9800";
                          } else if (result.status_code >= 500) {
                            statusColor = "#f44336";
                          }
                          return (
                            <div
                              key={result.id}
                              style={{
                                display: "flex",
                                justifyContent: "space-between",
                                alignItems: "center",
                                padding: "0.8em",
                                background: "#fff",
                                borderRadius: 6,
                                border: "1px solid #e3e8ee"
                              }}
                            >
                              <div>
                                <div style={{ fontWeight: 500 }}>Status: {result.status_code}</div>
                                <div style={{ fontSize: "0.9em", color: "#666" }}>
                                  Response Time: {result.response_time_ms}ms
                                </div>
                                <div style={{ fontSize: "0.9em", color: "#666" }}>
                                  Checked at: {new Date(result.checked_at).toLocaleString()}
                                </div>
                              </div>
                              <div
                                style={{
                                  width: 12,
                                  height: 12,
                                  borderRadius: "50%",
                                  background: statusColor
                                }}
                              />
                            </div>
                          );
                        })}
                      </div>
                    ) : (
                      <div style={{ color: "#666", textAlign: "center", padding: "1em" }}>
                        No check history available
                      </div>
                    )}
                  </div>
                )}
              </div>
            </li>
          );
        })}
      </ul>
    </div>
  );
};

export default EndpointList;
