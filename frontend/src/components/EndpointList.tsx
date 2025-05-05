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
            </li>
          );
        })}
      </ul>
    </div>
  );
};

export default EndpointList;
