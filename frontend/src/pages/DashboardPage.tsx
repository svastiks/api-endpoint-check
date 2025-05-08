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
    <div>
      <header
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          padding: "1rem 2rem",
          borderBottom: "1px solid #eee",
        }}
      >
        <h1 style={{ margin: 0, fontSize: "1.5rem" }}>API Endpoint Dashboard</h1>
        <button onClick={logout} style={{ padding: "0.5rem 1rem" }}>
          Logout
        </button>
      </header>
      <main style={{ maxWidth: 700, margin: "2rem auto" }}>
        <AddEndpointForm onSuccess={handleAddSuccess} />
        <EndpointList />
      </main>
    </div>
  );
};

export default DashboardPage;
