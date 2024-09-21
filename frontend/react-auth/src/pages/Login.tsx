import React, { useState, SyntheticEvent } from 'react';
import axios from 'axios';
import { Navigate, Link } from 'react-router-dom';

const Login: React.FC<{ setLogin: (loggedIn: boolean) => void }> = ({ setLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [redirect, setRedirect] = useState(false);
  const submit = async (e: SyntheticEvent) => {
    e.preventDefault();

    // Using environment variable for API URL
    const apiURL = process.env.REACT_APP_API_URL || 'http://localhost:3000'; // Fallback to localhost if environment variable is not set

    try {
        // Fix axios.post call with URL and data as separate arguments
        const response = await axios.post(`${apiURL}/api/login`, {
          email, // Simplification, since the name of the property and variable are the same
          password,
        });

        // Check the response here (example: whether login was successful based on the response status)
        if (response.status === 200) {
          // If the response is successful, set the state to redirect
          setLogin(true);
          setRedirect(true);
        } else {
          // Here you can handle other status codes or set a state to display an error message
          console.error("Login falhou com status:", response.status);
          // Ideally I would set an error state here to inform the user that login failed
        }
      } catch (error) {
      console.error("Erro ao fazer login:", error);
      // Here you could also set an error state to inform the user about the problem
    }
  };

  if(redirect){
    return <Navigate to="/"/>;
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
      <p className="mt-5 mb-3 text-body-secondary">&copy; 2017–2024</p>
    </form>
  );
}
export default Login;