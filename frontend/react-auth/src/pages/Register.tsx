import React, {useState, SyntheticEvent} from 'react';
import axios, { AxiosError } from 'axios';

const Register: React.FC = () => {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  const submit = async (e: SyntheticEvent) => {
    e.preventDefault();
    // Using environment variable for API URL
    // const apiURL = window._env_?.REACT_APP_API_URL || process.env.REACT_APP_API_URL || 'http://localhost:3000';
    const apiURL = window._env_?.REACT_APP_API_URL || process.env.REACT_APP_API_URL
    console.log("REACT_APP_API_URL:", window._env_.REACT_APP_API_URL)
    console.log("Submitting login request to:", apiURL);
    
    try {
        const response = await axios.post(`${apiURL}/api/register`, {
            first_name: firstName,
            last_name: lastName,
            email: email,
            password: password,
            confirm_password: confirmPassword,
        });
        console.log(response);
    } catch (error) {
        // Asserção de tipo para AxiosError
        const axiosError = error as AxiosError; // Importar AxiosError de 'axios'

        console.error("Error registering:", axiosError.response ? axiosError.response.data : axiosError.message);
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
        <input type="password" className="form-control" placeholder="Password Confirm" required 
          onChange={e => setConfirmPassword(e.target.value)}
        />
      </div>
      <button className="form-signin btn btn-primary w-100 py-2" type="submit">Register</button>
     <p className="mt-5 mb-3 text-body-secondary">&copy; 2017–2024</p>
    </form>
  );
}
export default Register;