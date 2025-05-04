import React, { useState, useContext, FormEvent } from "react";
import api from "../api/axios";
import { AuthContext } from "../context/AuthContext";

const Login: React.FC = () => {
  const { setToken } = useContext(AuthContext);
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);

  // Handle form submission
  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault(); // Prevent a page reload
    setError(null); 
    setIsLoading(true);

    try {
      const response = await api.post("/login", {email, password});
      const { token } = response.data;
      setToken(token);

    } catch (err: any) {
      setError("Login failed. Please check your credentials.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {}
      {error && <p style={{ color: "red" }}>{error}</p>}

      <div>
        <label htmlFor="email">Email:</label>
        <input
          type="email"
          id="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)} 
          required
          disabled={isLoading}
        />
      </div>
      <div>
        <label htmlFor="password">Password:</label>
        <input
          type="password"
          id="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          disabled={isLoading}
        />
      </div>
      <button type="submit" disabled={isLoading}>
        {}
        {isLoading ? "Logging in..." : "Login"}
      </button>
      {}
    </form>
  );
};

export default Login;
