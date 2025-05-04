import React, { useContext } from "react";
import { AuthContext } from "../context/AuthContext";

const DashboardPage: React.FC = () => {
  const { logout } = useContext(AuthContext);

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
      {}
    </div>
  );
};

export default DashboardPage;
