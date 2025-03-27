import React, { useState, useEffect } from "react";
import axios from "axios";
import "./App.css";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Home from "./pages/Home";
import Register from "./pages/Register";
import Forgot from "./pages/Forgot";
import Reset from "./pages/Reset";
import Nav from "./components/Nav";

// Configurar axios com a URL base
axios.defaults.baseURL = process.env.REACT_APP_API_URL + '/api';
axios.defaults.withCredentials = true; // Importante para cookies

function App() {
  const [user, setUser] = useState(null);
  const [login, setLogin] = useState(false);
  const [loading, setLoading] = useState(true); // Adicionar loading state

  useEffect(() => {
    (async () => {
      try {
        const response = await axios.get("/user");
        setUser(response.data);
      } catch (e) {
        if (process.env.REACT_APP_LOG_LEVEL === 'debug') {
          console.error("Error loading user data", e);
        }
        setUser(null);
      } finally {
        setLoading(false);
      }
    })();
  }, [login]);

  if (loading) {
    return <div>Loading...</div>; // Ou um componente de loading mais elaborado
  }

  return (
    <div className="App">
      <Router>
        <Nav user={user} setLogin={() => setLogin(false)} />
        <Routes>
          <Route path="/login" element={<Login setLogin={() => setLogin(true)} />} />
          <Route path="/register" element={<Register />} />
          <Route path="/forgot" element={<Forgot />} />
          <Route path="/reset/:token" element={<Reset />} />
          <Route path="/" element={<Home user={user} />} />
        </Routes>
      </Router>
    </div>
  );
}

export default App;