import React, { useState, SyntheticEvent, useEffect } from "react";
import axios from "axios";
import { Navigate, useParams } from "react-router-dom";

const getApiUrl = () => {
  const url = window._env_?.REACT_APP_API_URL || process.env.REACT_APP_API_URL || '/api';
  console.log("API URL:", url);
  return url;
};

const Reset = () => {
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [redirect, setRedirect] = useState(false);
  const [apiUrl, setApiUrl] = useState('');
  const { token } = useParams<{ token: string }>();

  useEffect(() => {
    const url = getApiUrl();
    setApiUrl(url);
    console.log("Initial API URL:", url);
  }, []);

  const submit = async (e: SyntheticEvent) => {
    e.preventDefault();

    if (password !== confirmPassword) {
      console.error("Passwords do not match!");
      return;
    }

    console.log("Submitting password reset request to:", apiUrl);

    try {
      // POST request to the /api/reset route with the necessary data
      await axios.post(`/reset`, {
        token,
        password,
        confirm_password: confirmPassword,
      }, {
        headers: {
          'Content-Type': 'application/json',
        },
      });

      setRedirect(true);
    } catch (error: any) {
      console.error("Failed to reset password:", error.response ? error.response.data : error.message);

      if (error.response) {
        console.error("Server response error:", error.response.data);
        console.error("Status code:", error.response.status);
        console.error("Headers:", error.response.headers);
      } else if (error.request) {
        console.error("Request error:", error.request);
      } else {
        console.error("Error:", error.message);
      }
      console.error("Error config:", error.config);
    }
  };

  // Redirect to the login page if the password reset is successful
  if (redirect) {
    return <Navigate to="/login" />;
  }

  return (
    <form className="form-floating" onSubmit={submit}>
      <h1 className="h3 mb-3 font-weight-normal">Reset your password</h1>
      <div className="form-signin">
        <input
          type="password"
          className="form-control mb-3"
          placeholder="New Password"
          required
          onChange={(e) => setPassword(e.target.value)}
        />
      </div>
      <div className="form-signin">
        <input
          type="password"
          className="form-control mb-3"
          placeholder="Confirm Password"
          required
          onChange={(e) => setConfirmPassword(e.target.value)}
        />
      </div>
      <button className="form-signin btn btn-primary w-100 py-2" type="submit">
        Reset Password
      </button>
      <p className="mt-5 mb-3 text-body-secondary">&copy; Código Fluente 2024</p>
    </form>
  );
};

export default Reset;
