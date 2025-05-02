import React, { useState, FormEvent } from "react";
import axios from "axios";

// Expected API response on successful login
interface LoginResponse {
  token: string;
  user_id: number;
  email: string;
}

const Login: React.FC = () => {
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
      const response = await axios.post<LoginResponse>(
        "http://localhost:4000/api/login",
        {
          email: email,
          password: password,
        }
      );

      console.log("Login successful:", response.data);
      const { token } = response.data;

      alert(`Login successful! Token: ${token}`);
    } catch (err) {

      console.error("Login error:", err);
      let errorMessage = "Login failed. Please check your credentials.";

      if (axios.isAxiosError(err) && err.response) {
        if (err.response.data && err.response.data.error) {
          errorMessage = err.response.data.error;
        } else if (err.response.status === 401) {
          errorMessage = "Invalid email or password.";
        }
      }
      setError(errorMessage);
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
