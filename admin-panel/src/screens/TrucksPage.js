import React, { useEffect, useState, useCallback } from "react";
import axios from "axios";
import "../styles/table.css"; // Assuming you have general table styling
import Sidebar from "../components/Sidebar";

const TrucksPage = () => {
  const [trucks, setTrucks] = useState([]);
  const [editingTruck, setEditingTruck] = useState(null); // Holds _id of truck being edited, or "new" for creation
  const [formData, setFormData] = useState({}); // Form data for editing/creating
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Pagination State
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(10); // Items per page
  const [totalPages, setTotalPages] = useState(1);
  const [totalItems, setTotalItems] = useState(0);

  // useCallback for fetchTrucks to optimize performance
  const fetchTrucks = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        setError("Authentication token not found. Please log in.");
        setLoading(false);
        return;
      }

      // Parameters for pagination
      const params = { page, limit };

      const res = await axios.get("http://localhost:5000/api/trucks/admin", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
        params: params, // Pass pagination parameters
      });
      setTrucks(res.data.trucks);
      setTotalPages(res.data.totalPages);
      setTotalItems(res.data.totalItems);
    } catch (err) {
      console.error("Error fetching trucks:", err);
      if (err.response) {
        if (err.response.status === 401 || err.response.status === 403) {
          setError(
            "You are not authorized to view trucks. Please check your permissions."
          );
        } else if (err.response.status === 404) {
          setError(
            "The trucks endpoint was not found. Please check the backend URL."
          );
        } else {
          setError(
            `Failed to fetch trucks: ${
              err.response.data.message || err.response.statusText
            }`
          );
        }
      } else if (err.request) {
        setError("No response from server. Check if the backend is running.");
      } else {
        setError("An unexpected error occurred while setting up the request.");
      }
    } finally {
      setLoading(false);
    }
  }, [page, limit]); // Dependencies for useCallback

  // useEffect to call fetchTrucks when component mounts or page/limit changes
  useEffect(() => {
    fetchTrucks();
  }, [fetchTrucks]);

  // Handle click on Edit button
  const handleEditClick = (truck) => {
    setEditingTruck(truck._id);
    // Initialize formData with truck data, specifically handling nested objects
    setFormData({
      ...truck,
      // Flatten location fields for form inputs
      location_latitude: truck.location?.latitude || "",
      location_longitude: truck.location?.longitude || "",
      location_address_string: truck.location?.address_string || "",
      // Flatten operating_hours fields for form inputs
      operating_hours_open: truck.operating_hours?.open || "",
      operating_hours_close: truck.operating_hours?.close || "",
      // Include owner_id for potential display or re-assignment if needed (for new trucks)
      owner_id: truck.owner_id?._id || "",
    });
  };

  // Handle input changes, including nested object properties
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    // Check for nested properties and update formData correctly
    if (name.startsWith("location_")) {
      const prop = name.split("_")[1]; // 'latitude', 'longitude', 'address_string'
      setFormData((prev) => ({
        ...prev,
        location: {
          ...(prev.location || {}), // Ensure location object exists
          [prop]: value,
        },
        // Also keep the flattened fields for direct input value binding
        [name]: value,
      }));
    } else if (name.startsWith("operating_hours_")) {
      const prop = name.split("_")[2]; // 'open', 'close'
      setFormData((prev) => ({
        ...prev,
        operating_hours: {
          ...(prev.operating_hours || {}), // Ensure operating_hours object exists
          [prop]: value,
        },
        // Keep flattened fields for direct input value binding
        [name]: value,
      }));
    } else {
      setFormData({ ...formData, [name]: value });
    }
  };

  // Cancel editing/creation
  const handleCancelEdit = () => {
    setEditingTruck(null);
    setFormData({});
  };

  // Save changes (create or update)
  const handleSaveEdit = async () => {
    const token = localStorage.getItem("token");
    if (!token) {
      alert("Authentication token not found. Please log in.");
      return;
    }

    // Construct the payload based on the flattened formData
    const payload = { ...formData };

    // Reconstruct nested location object from flattened fields
    payload.location = {
      latitude: parseFloat(payload.location_latitude) || 0,
      longitude: parseFloat(payload.location_longitude) || 0,
      address_string: payload.location_address_string || "",
    };
    // Clean up flattened fields from payload
    delete payload.location_latitude;
    delete payload.location_longitude;
    delete payload.location_address_string;

    // Reconstruct nested operating_hours object from flattened fields
    payload.operating_hours = {
      open: payload.operating_hours_open || "",
      close: payload.operating_hours_close || "",
    };
    // Clean up flattened fields from payload
    delete payload.operating_hours_open;
    delete payload.operating_hours_close;

    try {
      if (editingTruck === "new") {
        // Validation for new truck
        if (
          !payload.owner_id ||
          !payload.truck_name ||
          !payload.cuisine_type ||
          !payload.city
        ) {
          alert(
            "Please fill in all required fields for a new truck (Owner ID, Name, Cuisine, City)."
          );
          return;
        }

        const res = await axios.post(
          "http://localhost:5000/api/trucks", // Admin can use this endpoint to create trucks
          payload,
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
        );
        alert("✅ Truck created successfully!");
      } else {
        // Admin update uses the specific admin route
        const res = await axios.put(
          `http://localhost:5000/api/trucks/admin/${editingTruck}`,
          payload,
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
        );
        alert("✅ Truck updated successfully!");
      }
      setEditingTruck(null);
      setFormData({}); // Clear form
      fetchTrucks(); // Re-fetch to update the table
    } catch (err) {
      console.error("Error saving truck:", err);
      if (err.response) {
        alert(
          `❌ Failed to save truck: ${
            err.response.data.message || err.response.statusText
          }`
        );
      } else {
        alert("❌ Failed to save truck. Network error or server unreachable.");
      }
    }
  };

  // Handle truck deletion
  const handleDelete = async (id) => {
    const confirmDelete = window.confirm(
      "Are you sure you want to delete this truck? This action cannot be undone."
    );
    if (!confirmDelete) return;

    const token = localStorage.getItem("token");
    if (!token) {
      alert("Authentication token not found. Please log in.");
      return;
    }

    try {
      // Admin delete uses the specific admin route
      await axios.delete(`http://localhost:5000/api/trucks/admin/${id}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      alert("🗑️ Truck deleted successfully!");
      fetchTrucks(); // Re-fetch to update the table
    } catch (err) {
      console.error("Delete failed:", err);
      if (err.response) {
        alert(
          `❌ Failed to delete truck: ${
            err.response.data.message || err.response.statusText
          }`
        );
      } else {
        alert(
          "❌ Failed to delete truck. Network error or server unreachable."
        );
      }
    }
  };

  // Pagination Handlers
  const handleNextPage = () => {
    if (page < totalPages) {
      setPage(page + 1);
    }
  };

  const handlePrevPage = () => {
    if (page > 1) {
      setPage(page - 1);
    }
  };

  return (
    <div className="dashboard-container">
      <Sidebar />
      <div className="main-panel">
        {/* TOP CONTROLS: TRUCK TITLE ON LEFT, BUTTONS & PAGINATION ON RIGHT */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between", // Puts space between title and right-aligned group
            alignItems: "center",
            marginBottom: "20px", // Add some space below this top row
            flexWrap: "wrap", // Allow items to wrap on smaller screens
            gap: "15px", // Space between items when wrapped
          }}
        >
          {/* Page Title - Now on the left */}
          <h2>🚚 Manage Trucks (Admin)</h2>

          {/* Right-aligned group: Add Truck Button + Pagination Controls */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "10px", // Space between add truck button and pagination controls
              flexWrap: "wrap", // Allow items to wrap on smaller screens
              justifyContent: "flex-end", // Align items to the right within this flex container
            }}
          >
            {/* Add New Truck Button - Modified Styling */}
            <button
              className="add-truck-btn" // New class for distinct styling
              onClick={() => {
                setEditingTruck("new"); // Set to "new" to indicate creation mode
                setFormData({
                  truck_name: "",
                  cuisine_type: "",
                  description: "",
                  logo_image_url: "",
                  location_latitude: "",
                  location_longitude: "",
                  location_address_string: "",
                  operating_hours_open: "",
                  operating_hours_close: "",
                  city: "",
                  owner_id: "", // Important: Admin needs to specify owner_id for new trucks
                });
              }}
              style={{
                padding: "12px 25px", // Larger padding
                backgroundColor: "#28a745", // Green color
                color: "white",
                border: "none",
                borderRadius: "5px",
                cursor: "pointer",
                fontSize: "1rem", // Larger font size
                fontWeight: "bold",
                boxShadow: "0 2px 4px rgba(0,0,0,0.2)", // Subtle shadow
                transition: "background-color 0.3s ease",
              }}
            >
              ➕ Add New Truck
            </button>

            {/* Pagination Controls */}
            <div
              className="pagination-controls"
              style={{
                display: "flex",
                justifyContent: "center", // Center pagination buttons horizontally
                alignItems: "center",
                gap: "10px",
              }}
            >
              <button
                onClick={handlePrevPage}
                disabled={page === 1}
                style={{
                  padding: "8px 15px",
                  backgroundColor: "#007bff",
                  color: "white",
                  border: "none",
                  borderRadius: "4px",
                  cursor: "pointer",
                }}
              >
                Previous
              </button>
              <span style={{ alignSelf: "center" }}>
                Page {page} of {totalPages} ({totalItems} items)
              </span>
              <button
                onClick={handleNextPage}
                disabled={page === totalPages}
                style={{
                  padding: "8px 15px",
                  backgroundColor: "#007bff",
                  color: "white",
                  border: "none",
                  borderRadius: "4px",
                  cursor: "pointer",
                }}
              >
                Next
              </button>
              {/* Items per page selector */}
              <select
                value={limit}
                onChange={(e) => {
                  setLimit(parseInt(e.target.value));
                  setPage(1); // Reset to first page when limit changes
                }}
                style={{
                  padding: "8px",
                  borderRadius: "4px",
                  border: "1px solid #ccc",
                }}
              >
                <option value="5">5 per page</option>
                <option value="10">10 per page</option>
                <option value="20">20 per page</option>
              </select>
            </div>
          </div>
        </div>

        {loading && <p>Loading trucks...</p>}
        {error && <p className="error-message">{error}</p>}
        {!loading && !error && trucks.length === 0 && <p>No trucks found.</p>}

        {!loading && !error && trucks.length > 0 && (
          <>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Owner</th>
                  <th>Cuisine</th>
                  <th>City</th>
                  <th>Location (Lat, Lng)</th>
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
                    <td>
                      {/* Display owner name if populated, otherwise ID */}
                      {t.owner_id?.F_name && t.owner_id?.L_name
                        ? `${t.owner_id.F_name} ${t.owner_id.L_name}`
                        : t.owner_id?._id || "Unknown"}
                    </td>
                    <td>{t.cuisine_type}</td>
                    <td>{t.city}</td>
                    <td>
                      {t.location?.address_string ? (
                        <>
                          {t.location.address_string} <br />(
                          {t.location.latitude?.toFixed(4)},{" "}
                          {t.location.longitude?.toFixed(4)})
                          <br />
                          {/* Google Maps link (ensure correct syntax) */}
                          <a
                            href={`http://maps.google.com/?q=${t.location.latitude},${t.location.longitude}`}
                            target="_blank"
                            rel="noreferrer"
                          >
                            View Map ↗️
                          </a>
                        </>
                      ) : (
                        "—"
                      )}
                    </td>
                    <td>
                      {t.operating_hours?.open && t.operating_hours?.close
                        ? `${t.operating_hours.open} - ${t.operating_hours.close}`
                        : "—"}
                    </td>
                    <td>
                      {t.logo_image_url ? (
                        <img
                          src={t.logo_image_url} // Assuming full URL from backend
                          alt="Logo"
                          width="40"
                          height="40"
                          style={{ objectFit: "cover", borderRadius: "50%" }}
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
          </>
        )}

        {/* Edit/Create Truck Form (Modal-like overlay) */}
        {editingTruck && (
          <div
            className="edit-order-form-overlay"
            style={{
              position: "fixed",
              top: 0,
              left: 0,
              width: "100%",
              height: "100%",
              backgroundColor: "rgba(0, 0, 0, 0.5)",
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              zIndex: 999,
            }}
          >
            <div
              className="edit-order-form-content"
              style={{
                backgroundColor: "#fff",
                padding: "20px",
                borderRadius: "8px",
                boxShadow: "0 4px 15px rgba(0, 0, 0, 0.2)",
                zIndex: 1000,
                minWidth: "350px",
                maxWidth: "600px",
                width: "90%",
                maxHeight: "80vh",
                overflowY: "auto",
              }}
            >
              <h3>
                {editingTruck === "new"
                  ? "Add New Truck"
                  : `Edit Truck: ${formData.truck_name || ""}`}
              </h3>

              <form onSubmit={(e) => e.preventDefault()}>
                {/* Only show Owner ID input for new trucks */}
                {editingTruck === "new" && (
                  <label style={{ display: "block", marginBottom: "10px" }}>
                    Owner ID:
                    <input
                      name="owner_id"
                      value={formData.owner_id || ""}
                      placeholder="Enter Owner ID (for new trucks)"
                      onChange={handleInputChange}
                      style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                      required={editingTruck === "new"} // Make required for new truck
                    />
                  </label>
                )}

                <label style={{ display: "block", marginBottom: "10px" }}>
                  Truck Name:
                  <input
                    name="truck_name"
                    value={formData.truck_name || ""}
                    placeholder="Truck Name"
                    onChange={handleInputChange}
                    style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                    required
                  />
                </label>
                <label style={{ display: "block", marginBottom: "10px" }}>
                  Cuisine Type:
                  <input
                    name="cuisine_type"
                    value={formData.cuisine_type || ""}
                    placeholder="Cuisine Type"
                    onChange={handleInputChange}
                    style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                    required
                  />
                </label>
                <label style={{ display: "block", marginBottom: "10px" }}>
                  Description:
                  <textarea
                    name="description"
                    value={formData.description || ""}
                    placeholder="Description"
                    onChange={handleInputChange}
                    rows="3"
                    style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                  />
                </label>
                <label style={{ display: "block", marginBottom: "10px" }}>
                  Logo Image URL:
                  <input
                    name="logo_image_url"
                    value={formData.logo_image_url || ""}
                    placeholder="Logo Image URL (e.g., http://localhost:5000/uploads/my_logo.png)"
                    onChange={handleInputChange}
                    style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                  />
                </label>
                <label style={{ display: "block", marginBottom: "10px" }}>
                  City:
                  <input
                    name="city"
                    value={formData.city || ""}
                    placeholder="City (e.g., Ramallah)"
                    onChange={handleInputChange}
                    style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                    required
                  />
                </label>

                {/* Location Inputs (based on your current truckModel) */}
                <fieldset
                  style={{
                    border: "1px solid #ccc",
                    padding: "10px",
                    margin: "10px 0",
                    borderRadius: "4px",
                  }}
                >
                  <legend style={{ fontWeight: "bold" }}>
                    Location Details
                  </legend>
                  <label style={{ display: "block", marginBottom: "10px" }}>
                    Address String:
                    <input
                      name="location_address_string"
                      value={formData.location_address_string || ""}
                      placeholder="e.g., 123 Main St, Anytown"
                      onChange={handleInputChange}
                      style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                    />
                  </label>
                  <label style={{ display: "block", marginBottom: "10px" }}>
                    Latitude:
                    <input
                      type="number"
                      name="location_latitude"
                      value={formData.location_latitude || ""}
                      placeholder="Latitude (e.g., 31.7687)"
                      onChange={handleInputChange}
                      step="any"
                      style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                    />
                  </label>
                  <label style={{ display: "block", marginBottom: "10px" }}>
                    Longitude:
                    <input
                      type="number"
                      name="location_longitude"
                      value={formData.location_longitude || ""}
                      placeholder="Longitude (e.g., 35.2137)"
                      onChange={handleInputChange}
                      step="any"
                      style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                    />
                  </label>
                </fieldset>

                {/* Operating Hours Inputs */}
                <fieldset
                  style={{
                    border: "1px solid #ccc",
                    padding: "10px",
                    margin: "10px 0",
                    borderRadius: "4px",
                  }}
                >
                  <legend style={{ fontWeight: "bold" }}>
                    Operating Hours
                  </legend>
                  <label style={{ display: "block", marginBottom: "10px" }}>
                    Open Time:
                    <input
                      type="time"
                      name="operating_hours_open"
                      value={formData.operating_hours_open || ""}
                      onChange={handleInputChange}
                      style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                    />
                  </label>
                  <label style={{ display: "block", marginBottom: "10px" }}>
                    Close Time:
                    <input
                      type="time"
                      name="operating_hours_close"
                      value={formData.operating_hours_close || ""}
                      onChange={handleInputChange}
                      style={{ width: "100%", padding: "8px", margin: "5px 0" }}
                    />
                  </label>
                </fieldset>

                <div
                  className="form-buttons"
                  style={{
                    marginTop: "1rem",
                    display: "flex",
                    justifyContent: "flex-end",
                    gap: "10px",
                  }}
                >
                  <button
                    type="submit"
                    onClick={handleSaveEdit}
                    className="save-btn"
                  >
                    Save Changes
                  </button>
                  <button
                    type="button"
                    onClick={handleCancelEdit}
                    className="cancel-btn"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default TrucksPage;
