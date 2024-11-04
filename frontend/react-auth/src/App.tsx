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

function App() {
  const [user, setUser] = useState(null); // State to store user data
  const [login, setLogin] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const response = await axios.get("user");
        const user = response.data;
        setUser(user);// Update the state with user data
      } catch (e) {
        console.error("Error loading user data", e);
        setUser(null); // Sets the user to null in case of error
      }
    })();
  }, [login]);

  return (
    <div className="App">
      <Router>
        <Nav user={user} setLogin={ () => setLogin(false) }/>
        <Routes>
          <Route path="/login" element={<Login setLogin={() => setLogin(true)} />} />
          <Route path="/register" element={<Register />} />
          <Route path="/forgot" element={<Forgot />} />
          <Route path="/reset/:token" element={<Reset />} />

          {/* Protected route that requires authentication */}
          <Route path="/" element={<Home user={user} />} />
        </Routes>
      </Router>
    </div>
  );
}

export default App;