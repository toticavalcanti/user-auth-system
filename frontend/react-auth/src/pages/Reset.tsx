import React, { useState, SyntheticEvent } from 'react';
import axios from 'axios';
import { Navigate, useParams } from 'react-router-dom';

const Reset = () => {
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [redirect, setRedirect] = useState(false);
  const { token } = useParams<{ token: string }>();

  const submit = async (e: SyntheticEvent) => {
    e.preventDefault();

    if (password !== confirmPassword) {
      console.error('Passwords do not match!');
      return;
    }

    try {
      // Use a consistent base URL, defined as an environment variable or fallback to localhostt
      const apiURL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

      // Make a POST request to the /api/reset route with the necessary data
      await axios.post(`${apiURL}/api/reset`, {
        token,
        password,
        confirm_password: confirmPassword,
      });

      setRedirect(true);
    } catch (e: any) {
      console.error('Failed to reset password:', e.response?.data || e.message);
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
          onChange={e => setPassword(e.target.value)}
        />
      </div>
      <div className="form-signin">
        <input
          type="password"
          className="form-control mb-3"
          placeholder="Confirm Password"
          required
          onChange={e => setConfirmPassword(e.target.value)}
        />
      </div>
      <button className="form-signin btn btn-primary w-100 py-2" type="submit">
        Reset Password
      </button>
      <p className="mt-5 mb-3 text-body-secondary">© 2017–2024</p>
    </form>
  );
};

export default Reset;