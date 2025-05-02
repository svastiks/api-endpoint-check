import React from 'react';
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom"

import './App.css';

import LoginPage from "./pages/LoginPage"
import Login from './components/Login';

function App() {

  const isAuthenticated = false;

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
            isAuthenticated ? <div>Dashboard Placeholder</div> /* <DashboardPage /> */ : <Navigate to="/login" />
          }
        />
        {/* 404 Not Found */}
        <Route path="*" element={<div>404 Not Found</div>} />
      </Routes>
    </Router>
  );
}

export default App;
