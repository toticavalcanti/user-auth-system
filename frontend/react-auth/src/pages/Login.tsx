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
    const apiURL = window._env_?.REACT_APP_API_URL || process.env.REACT_APP_API_URL || 'http://localhost:3000';


    console.log("REACT_APP_API_URL:", window._env_.REACT_APP_API_URL)
    console.log("Submitting login request to:", apiURL); // Verifique se a URL está correta

    try {
      const response = await axios.post(`${apiURL}/api/login`, {
        email,
        password,
      });

      console.log("Response received:", response.data); // Verifique se a resposta está correta

      if (response.status === 200) {
        localStorage.setItem('jwt', response.data.jwt); // Armazene o JWT
        setLogin(true);
        setRedirect(true); // Redirecione após login bem-sucedido
      } else {
        console.error("Login failed with status:", response.status);
      }
    } catch (error: any) {
      if (error.response) {
        // O servidor retornou uma resposta com erro (ex: 4xx ou 5xx)
        console.error("Erro de resposta do servidor:", error.response.data);
      } else if (error.request) {
        // A requisição foi feita, mas o servidor não respondeu
        console.error("Erro de requisição:", error.request);
      } else {
        // Algo aconteceu ao configurar a requisição
        console.error("Erro desconhecido:", error.message);
      }
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
      <p className="mt-5 mb-3 text-body-secondary">&copy; 2017–2024</p>
    </form>
  );
}
export default Login;
