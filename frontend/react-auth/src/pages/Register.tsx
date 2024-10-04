import React, { useState, SyntheticEvent, useEffect } from 'react';
import axios, { AxiosError } from 'axios';

const getApiUrl = () => {
  const url = window._env_?.REACT_APP_API_URL || process.env.REACT_APP_API_URL || '/api';
  //const url = window._env_?.REACT_APP_API_URL || process.env.REACT_APP_API_URL || 'http://localhost:3000';

  console.log("API URL:", url);
  return url;
};

const Register: React.FC = () => {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [apiUrl, setApiUrl] = useState('');

  useEffect(() => {
    const url = getApiUrl();
    setApiUrl(url);
    console.log("Initial API URL:", url);
  }, []);

  const submit = async (e: SyntheticEvent) => {
    e.preventDefault();

    console.log("Submitting register request to:", apiUrl);

    try {
      const response = await axios.post(`${apiUrl}/api/register`, {
        first_name: firstName,
        last_name: lastName,
        email: email,
        password: password,
        confirm_password: confirmPassword,
      }, {
        headers: {
          'Content-Type': 'application/json',
        },
      });

      console.log("Response received:", response.data);
    } catch (error) {
      const axiosError = error as AxiosError;

      console.error("Error registering:", axiosError.response ? axiosError.response.data : axiosError.message);

      if (axiosError.response) {
        console.error("Server response error:", axiosError.response.data);
        console.error("Status code:", axiosError.response.status);
        console.error("Headers:", axiosError.response.headers);
      } else if (axiosError.request) {
        console.error("Request error:", axiosError.request);
      } else {
        console.error("Error:", axiosError.message);
      }

      console.error("Error config:", axiosError.config);
    }
  };

  return (
    <form className='form-floating' onSubmit={submit}>
      <h1 className="h3 mb-3 fw-normal">Please register</h1>
      <div className="form-signin">
        <input className="form-control" placeholder="First Name" required 
          onChange={e => setFirstName(e.target.value)}
        />
      </div>
      <div className="form-signin">
        <input className="form-control" placeholder="Last Name" required 
          onChange={e => setLastName(e.target.value)}
        />
      </div>
      <div className="form-signin">
        <input type="email" className="form-control" placeholder="name@example.com" required 
          onChange={e => setEmail(e.target.value)}
        />
      </div>
      <div className="form-signin">
        <input type="password" className="form-control" placeholder="Password" required 
          onChange={e => setPassword(e.target.value)}
        />
      </div>
      <div className="form-signin">
        <input type="password" className="form-control" placeholder="Confirm Password" required 
          onChange={e => setConfirmPassword(e.target.value)}
        />
      </div>
      <button className="form-signin btn btn-primary w-100 py-2" type="submit">Register</button>
      <p className="mt-5 mb-3 text-body-secondary">© 2024</p>
      <p>Current API URL: {apiUrl}</p>
    </form>
  );
};

export default Register;
