import React, { useEffect, useState } from "react";
import api from "../api/axios";
import { Endpoint } from "../types/endpoint";
import { CheckResult } from "../types/endpoint";
import { fetchLatestCheckResult } from "../api/endpoints";

const EndpointList: React.FC = () => {
const [endpoints, setEndpoints] = useState<Endpoint[]>([]);
const [loading, setLoading] = useState<boolean>(true);
const [error, setError] = useState<string | null>(null);
const [latestResults, setLatestResults] = useState<Record<number, CheckResult | null>>({});
const [expandedId, setExpandedId] = useState<number | null>(null);
const [history, setHistory] = useState<Record<number, CheckResult[]>>({});

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

  if (loading) return <div>Loading endpoints...</div>;
  if (error) return <div style={{ color: "red" }}>{error}</div>;
  if (endpoints.length === 0) return <div>No endpoints configured yet.</div>;

  return (
    <div>
      <h2>Your Endpoints</h2>
      <ul style={{ listStyle: "none", padding: 0 }}>
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
                border: "1px solid #eee",
                borderRadius: "8px",
                margin: "1rem 0",
                padding: "1rem",
                background: "#fafbfc",
              }}
            >
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                <div>
                  <strong>{ep.name || ep.url}</strong>
                  <div style={{ fontSize: "0.9em", color: "#666" }}>{ep.url}</div>
                  <div style={{ fontSize: "0.9em", color: "#888" }}>
                    Email: {ep.notification_email || "—"}
                  </div>
                </div>
                <div>
                  <span
                    style={{
                      display: "inline-block",
                      minWidth: 40,
                      textAlign: "center",
                      padding: "0.3em 0.7em",
                      borderRadius: "1em",
                      background: statusColor,
                      color: "#fff",
                      fontWeight: "bold",
                    }}
                  >
                    {statusText}
                  </span>
                </div>
              </div>
              <div style={{ fontSize: "0.8em", color: "#aaa", marginTop: "0.5em" }}>
                Last checked:{" "}
                {latest && latest.checked_at
                  ? new Date(latest.checked_at).toLocaleString()
                  : "—"}
              </div>
              <button
                style={{ marginTop: "0.5em" }}
                onClick={() => setExpandedId(expandedId === ep.id ? null : ep.id)}
            >
                {expandedId === ep.id ? "Hide History" : "Show History"}
            </button>
            {expandedId === ep.id && (
                <div
                    style={{
                    marginTop: "1em",
                    background: "#fff",
                    border: "1px solid #ddd",
                    borderRadius: 8,
                    boxShadow: "0 2px 8px rgba(0,0,0,0.04)",
                    padding: "1em",
                    maxHeight: 250, // px
                    overflowY: "auto",
                    transition: "max-height 0.3s",
                    }}
                >
                    <h4 style={{ margin: "0 0 0.5em 0" }}>Check History</h4>
                    {history[ep.id] && history[ep.id].length > 0 ? (
                    <ul style={{ fontSize: "0.95em", paddingLeft: 0, margin: 0 }}>
                        {history[ep.id].map((check) => (
                        <li
                            key={check.id}
                            style={{
                            marginBottom: 8,
                            borderBottom: "1px solid #eee",
                            paddingBottom: 4,
                            listStyle: "none",
                            }}
                        >
                            <span>
                            <strong>Status:</strong> {check.status_code}
                            </span>
                            {" | "}
                            <span>
                            <strong>Response:</strong> {check.response_time_ms}ms
                            </span>
                            {" | "}
                            <span>
                            <strong>Checked:</strong> {new Date(check.checked_at).toLocaleString()}
                            </span>
                        </li>
                        ))}
                    </ul>
                    ) : (
                    <div>No history found.</div>
                    )}
                </div>
                )}
            </li>
        );
        })}
      </ul>
    </div>
  );
};

export default EndpointList;
