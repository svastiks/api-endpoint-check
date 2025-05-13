import React, { useContext, useState } from "react";
import EndpointList from "../components/EndpointList";
import AddEndpointForm from "../components/AddEndpointForm";
import { AuthContext } from "../context/AuthContext";
import { Endpoint } from "../types/endpoint";

const DashboardPage: React.FC = () => {
  const { logout } = useContext(AuthContext);
  const [refresh, setRefresh] = useState(0);

  const handleAddSuccess = (endpoint: Endpoint) => {
    setRefresh(r => r + 1); // Triggers EndpointList to reload
  };

  return (
    <div style={{
      minHeight: "100vh",
      background: "linear-gradient(120deg, #f8fafc 0%, #e0e7ef 100%)",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "flex-start"
    }}>
      <header
        style={{
          width: "100%",
          maxWidth: 1100,
          margin: "2rem auto 0 auto",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          padding: "1.5rem 2.5rem",
          borderRadius: 16,
          background: "#fff",
          boxShadow: "0 2px 16px rgba(0,0,0,0.06)",
        }}
      >
        <h1 style={{ margin: 0, fontSize: "2rem", fontWeight: 700, letterSpacing: -1 }}>API Endpoint Dashboard</h1>
        <button onClick={logout} style={{ padding: "0.7rem 1.5rem", borderRadius: 8, border: "none", background: "#f44336", color: "#fff", fontWeight: 600, fontSize: 16, cursor: "pointer" }}>
          Logout
        </button>
      </header>
      <main style={{
        width: "100%",
        maxWidth: 1100,
        margin: "2.5rem auto",
        background: "#fff",
        borderRadius: 16,
        boxShadow: "0 2px 16px rgba(0,0,0,0.06)",
        padding: "2.5rem 2.5rem 2rem 2.5rem",
        display: "flex",
        flexDirection: "row",
        gap: "3rem",
        alignItems: "flex-start"
      }}>
        <div style={{ flex: 1, minWidth: 320, maxWidth: 400 }}>
          <AddEndpointForm onSuccess={handleAddSuccess} />
        </div>
        <div style={{ flex: 2, minWidth: 0 }}>
          <EndpointList />
        </div>
      </main>
    </div>
  );
};

export default DashboardPage;
