import React from 'react';

type UserProps = {
    user: {
        first_name: string;
        last_name: string;
        email?: string;
    } | null;  // Indicates that user can be an object with user data or null
};

const Home: React.FC<UserProps> = ({ user }) => {
  let message;
  if(user){
    message = `Hi ${user.first_name} ${user.last_name}`;
  } else{
    message = 'You are not logged in!';
  }
  return (
    <div className="container">
      <h1>{message}</h1>
    </div>
  );
}

export default Home