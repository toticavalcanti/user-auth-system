import React, { useState } from 'react';
import axios from "axios";
import { Link } from "react-router-dom";
const Nav = ({ user, setLogin }: { user: any, setLogin: (loggedIn: boolean) => void }) => {
  const logout = async () => {
    await axios.post('logout', {});
    setLogin(false);
  }
  let links;
  if(user){
    links = (
      <ul className="navbar-nav ms-auto">
        <li className="nav-item">
          <Link className="nav-link" to="/" onClick={logout}>Logout</Link>
        </li>
      </ul>
    )
  } else {
    links = (
      <ul className="navbar-nav ms-auto">
        <li className="nav-item">
          <Link className="nav-link" to="/login">Login</Link>
        </li>
        <li className="nav-item">
          <Link className="nav-link" to="/register">Register</Link>
        </li>
      </ul>
    )
  }
  const [isNavCollapsed, setIsNavCollapsed] = useState(true);
  const handleNavCollapse = () => setIsNavCollapsed(!isNavCollapsed);
  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-dark">
      <div className="container-fluid">
        <Link className="navbar-brand" to="/">Home</Link>
        <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded={!isNavCollapsed} aria-label="Toggle navigation" onClick={handleNavCollapse}>
          <span className="navbar-toggler-icon"></span>
        </button>
        <div className={`${isNavCollapsed ? 'collapse' : ''} navbar-collapse`} id="navbarNav">
          <ul className="navbar-nav ms-auto">
            {links}
          </ul>
        </div>
      </div>
    </nav>
  );
};

export default Nav;