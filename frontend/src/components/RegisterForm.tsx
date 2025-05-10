import React, { useState } from "react";
import api from "../api/axios";
import { useNavigate } from "react-router-dom";

const RegisterForm: React.FC = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      await api.post("/register", { email, password });
      // Optionally show a success message here
      navigate("/login");
    } catch (err: any) {
      setError("Registration failed. Email may already be taken.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ maxWidth: 400 }}>
      {error && <div style={{ color: "red" }}>{error}</div>}
      <div>
        <label>
          Email:{" "}
          <input
            type="email"
            value={email}
            onChange={e => setEmail(e.target.value)}
            required
            disabled={loading}
          />
        </label>
      </div>
      <div>
        <label>
          Password:{" "}
          <input
            type="password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            required
            minLength={8}
            disabled={loading}
          />
        </label>
      </div>
      <button type="submit" disabled={loading}>
        {loading ? "Registering..." : "Register"}
      </button>
    </form>
  );
};

export default RegisterForm;
