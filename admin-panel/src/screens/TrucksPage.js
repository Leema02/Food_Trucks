import React, { useEffect, useState } from "react";
import axios from "axios";
import "../styles/table.css";
import Sidebar from "../components/Sidebar";

const TrucksPage = () => {
  const [trucks, setTrucks] = useState([]);
  const [editingTruck, setEditingTruck] = useState(null);
  const [formData, setFormData] = useState({});
  const fetchTrucks = async () => {
    try {
      const res = await axios.get(
        "http://localhost:5000/api/trucks/my-trucks",
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        }
      );
      setTrucks(res.data);
    } catch (err) {
      console.error("Error fetching trucks:", err);
    }
  };

  useEffect(() => {
    fetchTrucks();
  }, []);

  const handleEditClick = (truck) => {
    setEditingTruck(truck._id);
    setFormData({ ...truck });
  };

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleCancelEdit = () => {
    setEditingTruck(null);
    setFormData({});
  };

  const handleSaveEdit = async () => {
    try {
      if (editingTruck === "new") {
        const res = await axios.post(
          "http://localhost:5000/api/trucks",
          formData,
          {
            headers: {
              Authorization: `Bearer ${localStorage.getItem("token")}`,
            },
          }
        );
        setTrucks([...trucks, res.data]);
        alert("✅ Truck created");
      } else {
        const res = await axios.put(
          `http://localhost:5000/api/trucks/${editingTruck}`,
          formData,
          {
            headers: {
              Authorization: `Bearer ${localStorage.getItem("token")}`,
            },
          }
        );
        const updated = trucks.map((t) =>
          t._id === editingTruck ? res.data : t
        );
        setTrucks(updated);
        alert("✅ Truck updated");
      }
      setEditingTruck(null);
      setFormData({});
    } catch (err) {
      console.error("Error saving truck:", err);
      alert("❌ Failed to save truck");
    }
  };

  const handleDelete = async (id) => {
    const confirm = window.confirm(
      "Are you sure you want to delete this truck?"
    );
    if (!confirm) return;

    try {
      await axios.delete(`http://localhost:5000/api/trucks/${id}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      setTrucks(trucks.filter((t) => t._id !== id));
      alert("🗑️ Truck deleted");
    } catch (err) {
      console.error("Delete failed", err);
      alert("❌ Failed to delete truck");
    }
  };

  return (
    <div className="dashboard-container">
      <Sidebar />
      <div className="main-panel">
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <h2>🚚 My Trucks</h2>
          <button
            className="edit-btn"
            onClick={() => {
              setEditingTruck("new");
              setFormData({
                truck_name: "",
                cuisine_type: "",
                description: "",
                logo_image_url: "",
                location: "",
                operating_hours: "",
                city: "",
              });
            }}
          >
            + New Truck
          </button>
        </div>

        <table className="admin-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Cuisine</th>
              <th>City</th>
              <th>Location</th>
              <th>Hours</th>
              <th>Logo</th>
              <th>Description</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {trucks.map((t) => (
              <tr key={t._id}>
                <td>{t.truck_name}</td>
                <td>{t.cuisine_type}</td>
                <td>{t.city}</td>
                <td>
                  <a href={t.location} target="_blank" rel="noreferrer">
                    📍 Map
                  </a>
                </td>
                <td>{t.operating_hours}</td>
                <td>
                  {t.logo_image_url ? (
                    <img
                      src={t.logo_image_url}
                      alt="Logo"
                      width="40"
                      height="40"
                    />
                  ) : (
                    "—"
                  )}
                </td>
                <td>{t.description}</td>
                <td>
                  <button
                    className="edit-btn"
                    onClick={() => handleEditClick(t)}
                  >
                    Edit
                  </button>
                  <button
                    className="delete-btn"
                    onClick={() => handleDelete(t._id)}
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {editingTruck && (
          <div className="edit-user-form">
            <h3>{editingTruck === "new" ? "New Truck" : "Edit Truck"}</h3>

            <form onSubmit={(e) => e.preventDefault()}>
              <input
                name="truck_name"
                value={formData.truck_name || ""}
                placeholder="Truck Name"
                onChange={handleInputChange}
              />
              <input
                name="cuisine_type"
                value={formData.cuisine_type || ""}
                placeholder="Cuisine Type"
                onChange={handleInputChange}
              />
              <input
                name="description"
                value={formData.description || ""}
                placeholder="Description"
                onChange={handleInputChange}
              />
              <input
                name="logo_image_url"
                value={formData.logo_image_url || ""}
                placeholder="Logo Image URL"
                onChange={handleInputChange}
              />
              <input
                name="location"
                value={formData.location || ""}
                placeholder="Google Maps Location URL"
                onChange={handleInputChange}
              />
              <input
                name="operating_hours"
                value={formData.operating_hours || ""}
                placeholder="Operating Hours"
                onChange={handleInputChange}
              />
              <input
                name="city"
                value={formData.city || ""}
                placeholder="City"
                onChange={handleInputChange}
              />

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

export default TrucksPage;
