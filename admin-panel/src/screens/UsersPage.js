import React, { useEffect, useState } from "react";
import axios from "axios";
import "../styles/table.css";
import Sidebar from "../components/Sidebar";

const UsersPage = () => {
  const [users, setUsers] = useState([]);
  const [editingUser, setEditingUser] = useState(null);
  const [formData, setFormData] = useState({});
  const [searchTerm, setSearchTerm] = useState("");

useEffect(() => {
  fetchUsers();
}, [searchTerm]);

  const fetchUsers = () => {
 const endpoint = searchTerm
  ? "http://localhost:5000/api/users/admin-search"
  : "http://localhost:5000/api/users";

axios
  .get(endpoint, {
    headers: {
      Authorization: `Bearer ${localStorage.getItem("token")}`,
    },
    params: {
      search: searchTerm || undefined,
    },
  })
    .then((res) => setUsers(res.data))
    .catch((err) => console.error("Error fetching users:", err));
};


  const handleEditClick = (user) => {
    setEditingUser(user._id);
    setFormData({ ...user });
  };

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleCancelEdit = () => {
    setEditingUser(null);
    setFormData({});
  };

  const handleSaveEdit = async () => {
    try {
      if (editingUser === "new") {
        const res = await axios.post(
          "http://localhost:5000/api/users/signup",
          formData,
          {
            headers: {
              Authorization: `Bearer ${localStorage.getItem("token")}`,
            },
          }
        );
        setUsers([...users, res.data.user]);
        alert("✅ New user added");
      } else {
        await axios.put(
          `http://localhost:5000/api/users/${editingUser}`,
          formData,
          {
            headers: {
              Authorization: `Bearer ${localStorage.getItem("token")}`,
            },
          }
        );
        const updated = users.map((u) =>
          u._id === editingUser ? formData : u
        );
        setUsers(updated);
        alert("✅ User updated");
      }

      setEditingUser(null);
      setFormData({});
    } catch (err) {
      console.error("Save failed", err);
      alert("❌ Failed to save user");
    }
  };

  const handleDelete = async (id) => {
    const confirm = window.confirm(
      "Are you sure you want to delete this user?"
    );
    if (!confirm) return;

    try {
      await axios.delete(`http://localhost:5000/api/users/${id}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      setUsers(users.filter((u) => u._id !== id));
      alert("🗑️ User deleted");
    } catch (err) {
      console.error("Delete failed", err);
      alert("❌ Failed to delete user");
    }
  };

  return (
    <div className="dashboard-container">
      
      <Sidebar />
      <div className="main-panel">
        <div style={{ margin: "20px 0", display: "flex", gap: "10px" }}>
  <input
    type="text"
    value={searchTerm}
    onChange={(e) => setSearchTerm(e.target.value)}
    placeholder="🔍 Search by name, email, or username"
    style={{
      padding: "8px",
      borderRadius: "4px",
      border: "1px solid #ccc",
      width: "250px",
    }}
  />
  <button
    onClick={() => fetchUsers()}
    style={{
      padding: "8px 16px",
      borderRadius: "4px",
      border: "none",
      backgroundColor: "#007bff",
      color: "white",
      cursor: "pointer",
    }}
  >
    Search
  </button>
  <button
    onClick={() => {
      setSearchTerm("");
      fetchUsers();
    }}
    style={{
      padding: "8px 16px",
      borderRadius: "4px",
      border: "none",
      backgroundColor: "#6c757d",
      color: "white",
      cursor: "pointer",
    }}
  >
    Clear
  </button>
</div>

        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <h2>Users</h2>
          <button
            className="edit-btn"
       onClick={() => {
  // Always clear form data first
  setFormData({
    F_name: "",
    L_name: "",
    email_address: "",
    phone_num: "",
    username: "",
    password: "",
    address: "",
    role_id: "",
    city: "",
  });

  // Then trigger the form to open
  setEditingUser("new");
}}


          >
            + New
          </button>
        </div>

        <table className="admin-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Username</th>
              <th>Phone</th>
              <th>Role</th>
              <th>City</th>
              <th>Address</th>
              <th>Created</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) =>
              u ? (
                <tr key={u._id}>
                  <td>
                    {u.F_name} {u.L_name}
                  </td>
                  <td>{u.email_address}</td>
                  <td>{u.username}</td>
                  <td>{u.phone_num}</td>
                  <td>{u.role_id}</td>
                  <td>{u.city}</td>
                  <td>{u.address}</td>
                  <td>
                    {u.createdAt
                      ? new Date(u.createdAt).toLocaleDateString()
                      : "—"}
                  </td>
                  <td>
                  
                 
                    <button
                      className="delete-btn"
                      onClick={() => handleDelete(u._id)}
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ) : null
            )}
          </tbody>
        </table>

       {(editingUser === "new" || typeof editingUser === "string") && (
  <div className="edit-user-form">
    <h3>{editingUser === "new" ? "New User" : "Edit User"}</h3>


            <form onSubmit={(e) => e.preventDefault()}>
              <input
                name="F_name"
                value={formData.F_name || ""}
                placeholder="First Name"
                onChange={handleInputChange}
              />
              <input
                name="L_name"
                value={formData.L_name || ""}
                placeholder="Last Name"
                onChange={handleInputChange}
              />
             <input
  name="email_address"
  value={formData.email_address || ""}
  onChange={handleInputChange}
  placeholder="Email"
/>

              <input
                name="phone_num"
                value={formData.phone_num || ""}
                placeholder="Phone"
                onChange={handleInputChange}
              />
              <input
                name="username"
                value={formData.username || ""}
                placeholder="Username"
                onChange={handleInputChange}
              />
              <input
                name="city"
                value={formData.city || ""}
                placeholder="City"
                onChange={handleInputChange}
              />
              <input
                name="address"
                value={formData.address || ""}
                placeholder="Address"
                onChange={handleInputChange}
              />
              <input
                name="role_id"
                value={formData.role_id || ""}
                placeholder="role"
                onChange={handleInputChange}
              />

              {editingUser === "new" && (
                <input
                  name="password"
                  type="password"
                  value={formData.password || ""}
                  placeholder="Password"
                  onChange={handleInputChange}
                />
              )}
              <div className="form-buttons" style={{ marginTop: "1rem" }}>
                <button type="button" onClick={handleSaveEdit}>
                  Save Changes
                </button>
                <button
                  type="button"
                  onClick={handleCancelEdit}
                  style={{ marginLeft: "8px" }}
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        )}
      </div>
    </div>
  );
};

export default UsersPage;
