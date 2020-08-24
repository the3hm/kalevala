import React from "react";

const Icon = ({ alt, className, icon }) => {
  return (
    <div className={`w-6 mr-2 ${className}`}>
      <img src={`/images/${icon}`} alt={alt} />
    </div>
  );
};

export default Icon;
