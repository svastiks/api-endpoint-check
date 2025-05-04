import React, { useContext } from 'react';
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom"
import LoginPage from "./pages/LoginPage"
import { AuthContext } from './context/AuthContext';
import DashboardPage from './pages/DashboardPage';

function App() {

  const { isAuthenticated } = useContext(AuthContext);

  return (
  <Router>
      <Routes>
        {/* If authenticated, to dashboard, else login */}
        <Route
          path="/"
          element={
            isAuthenticated ? (
              <Navigate to="/dashboard" />
            ) : (
              <Navigate to="/login" />
            )
          }
        />
        {/* Login Page Route */}
        <Route
          path="/login"
          element={
            isAuthenticated ? <Navigate to="/dashboard" /> : <LoginPage /> /* <LoginPage /> */
          }
        />
        {/* Register Page Route */}
        <Route
          path="/register"
          element={
            isAuthenticated ? <Navigate to="/dashboard" /> : <div>Register Page Placeholder</div> /* <RegisterPage /> */
          }
        />
        {/* Dashboard Route (Protected) */}
        <Route
          path="/dashboard"
          element={
            isAuthenticated ? <DashboardPage/> /* <DashboardPage /> */ : <Navigate to="/login" />
          }
        />
        {/* 404 Not Found */}
        <Route path="*" element={<div>404 Not Found</div>} />
      </Routes>
    </Router>
  );
}

export default App;
