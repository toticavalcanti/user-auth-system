import React, { useState, SyntheticEvent, useEffect } from 'react';
import axios from 'axios';
import { Navigate, Link } from 'react-router-dom';

const getApiUrl = () => {
  const url = window._env_?.REACT_APP_API_URL || process.env.REACT_APP_API_URL || '/api';
  console.log("API URL:", url);
  return url;
};

const Login: React.FC<{ setLogin: (loggedIn: boolean) => void }> = ({ setLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [redirect, setRedirect] = useState(false);
  const [apiUrl, setApiUrl] = useState('');

  useEffect(() => {
    const url = getApiUrl();
    setApiUrl(url);
    console.log("Initial API URL:", url);
  }, []);

  const submit = async (e: SyntheticEvent) => {
    e.preventDefault();
    console.log("Valor de window._env_:", window._env_);
    console.log("Submetendo o request de login para:", apiUrl);

    try {
      const response = await axios.post(`/login`, {
        email,
        password,
      }, {
        headers: {
          'Content-Type': 'application/json',
        },
      });

      console.log("Response received:", response.data);

      if (response.status === 200) {
        localStorage.setItem('jwt', response.data.jwt);
        setLogin(true);
        setRedirect(true);
      } else {
        console.error("Login failed with status:", response.status);
      }
    } catch (error: any) {
      console.error("Full error object:", error);
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

  if (redirect) {
    return <Navigate to="/" />;
  }

  return (
    <form className='form-floating' onSubmit={submit}>
      <h1 className="h3 mb-3 fw-normal">Please sign in</h1>
      <div className="form-signin">
        <input type="email" className="form-control" placeholder="name@example.com" required 
          onChange={e => setEmail(e.target.value)}
        />
      </div>
      <div className="form-signin">
        <input type="password" className="form-control" placeholder="Password" required 
          onChange={e => setPassword(e.target.value)}
        />
        <div className="mb-3">
          <Link to="/forgot">Forgot Password?</Link>
        </div>
      </div>
      <button className="form-signin btn btn-primary w-100 py-2" type="submit">Sign in</button>
      <p className="mt-5 mb-3 text-body-secondary">&copy; Código Fluente 2024</p>
    </form>
  );
}

export default Login;