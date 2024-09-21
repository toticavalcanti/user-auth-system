import React, { useState, SyntheticEvent } from 'react';
import axios from 'axios';

const Forgot = () => {
  const [email, setEmail] = useState('');
  const [notify, setNotify] = useState({
    show: false,
    error: false,
    message: ''
  });

  const submit = async (e: SyntheticEvent) => {
    e.preventDefault();
    try {
      await axios.post('forgot', {
        email
      });
      setNotify({
        show: true,
        error: false,
        message: 'Email was sent!'
      });
    } catch (e) {
      setNotify({
        show: true,
        error: true,
        message: 'Email does not exist!'
      });
    }
  };

  let info;
  if (notify.show) {
    info = (
      <div className={notify.error ? 'alert alert-danger' : 'alert alert-success'} role="alert">
        {notify.message}
      </div>
    );
  }

  return (
    <form className="form-floating" onSubmit={submit}>
      {info}
      <h1 className="h3 mb-3 font-weight-normal">Please set your email</h1>
      <div className="form-signin">
        <input
          type="email"
          className="form-control mb-3"
          placeholder="name@example.com"
          required
          onChange={e => setEmail(e.target.value)}
        />
      </div>
      <button className="form-signin btn btn-primary w-100 py-2" type="submit">
        Send Email
      </button>
      <p className="mt-5 mb-3 text-body-secondary">© 2017–2024</p>
    </form>
  );
};

export default Forgot;