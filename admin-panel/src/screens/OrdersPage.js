import React, { useEffect, useState, useCallback } from "react";
import axios from "axios";
import "../styles/table.css"; // Assuming you have general table styling
import Sidebar from "../components/Sidebar";

const OrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [editingOrder, setEditingOrder] = useState(null);
  const [formData, setFormData] = useState({}); // Used for the edit form
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Pagination and Filtering State
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(10);
  const [totalPages, setTotalPages] = useState(1);
  const [filterStatus, setFilterStatus] = useState("");
  const [filterOrderType, setFilterOrderType] = useState("");
  const [filterCustomerId, setFilterCustomerId] = useState("");
  const [filterTruckId, setFilterTruckId] = useState(""); // Correctly declared
  const [sortBy, setSortBy] = useState("createdAt");
  const [orderBy, setOrderBy] = useState("desc"); // 'asc' or 'desc'

  const statusOptions = ["Pending", "Preparing", "Ready", "Completed"];
  const orderTypeOptions = ["pickup", "delivery"];

  // fetchOrders is wrapped in useCallback to prevent unnecessary re-creations.
  // It depends on all state variables that influence the API request parameters.
  const fetchOrders = useCallback(async () => {
    setLoading(true);
    setError(null); // Clear previous errors
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        setError("Authentication token not found. Please log in.");
        setLoading(false);
        return;
      }

      const params = {
        page,
        limit,
        status: filterStatus,
        order_type: filterOrderType,
        customer_id: filterCustomerId,
        truck_id: filterTruckId,
        sortBy,
        orderBy,
      };

      // Remove empty parameters to avoid sending unnecessary query strings
      // This helps in cleaner backend logic and potentially cached responses
      Object.keys(params).forEach(
        (key) => params[key] === "" && delete params[key]
      );

      const res = await axios.get("http://localhost:5000/api/orders", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
        params: params,
      });

      setOrders(res.data.orders);
      setTotalPages(res.data.totalPages);
    } catch (err) {
      console.error("Error fetching orders:", err);
      // More user-friendly error messages based on common HTTP statuses
      if (err.response) {
        if (err.response.status === 401 || err.response.status === 403) {
          setError(
            "You are not authorized to view orders. Please check your permissions."
          );
        } else if (err.response.status === 404) {
          setError(
            "The orders endpoint was not found. Please check the backend URL."
          );
        } else {
          setError(
            `Failed to fetch orders: ${
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
  }, [
    page,
    limit,
    filterStatus,
    filterOrderType,
    filterCustomerId,
    filterTruckId, // Dependency for useCallback
    sortBy,
    orderBy,
  ]);

  // useEffect now only depends on fetchOrders.
  // fetchOrders itself changes only when its dependencies change,
  // preventing unnecessary re-runs of the effect.
  useEffect(() => {
    fetchOrders();
  }, [fetchOrders]);

  const handleEditClick = (order) => {
    setEditingOrder(order._id);
    // Initialize form data with the current order's status
    setFormData({ status: order.status });
  };

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleCancelEdit = () => {
    setEditingOrder(null);
    setFormData({});
  };

  const handleSaveEdit = async () => {
    // Basic validation
    if (!formData.status) {
      alert("Please select a status.");
      return;
    }

    try {
      const token = localStorage.getItem("token");
      if (!token) {
        // Added check for token existence
        alert("Authentication token not found. Please log in.");
        return;
      }
      await axios.put(
        `http://localhost:5000/api/orders/${editingOrder}`,
        { status: formData.status }, // This is the data you're sending
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      alert("✅ Order updated successfully!");
      setEditingOrder(null);
      setFormData({});
      fetchOrders(); // Re-fetch to show the updated status
    } catch (err) {
      console.error("Order update failed:", err);
      // Added more detailed logging for debugging
      console.log("Error response:", err.response);
      console.log("Error request:", err.request);
      console.log("Error message:", err.message);

      if (err.response) {
        alert(
          `❌ Failed to update order: ${
            err.response.data.message || err.response.statusText
          }`
        );
      } else {
        alert(
          "❌ Failed to update order. Network error or server unreachable."
        );
      }
    }
  };

  const handleDelete = async (id) => {
    const confirmDelete = window.confirm(
      "Are you sure you want to delete this order? This action cannot be undone."
    );
    if (!confirmDelete) return;

    try {
      const token = localStorage.getItem("token");
      if (!token) {
        // Added check for token existence
        alert("Authentication token not found. Please log in.");
        return;
      }
      await axios.delete(`http://localhost:5000/api/orders/${id}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      alert("🗑️ Order deleted successfully!");
      // Re-fetch orders to remove the deleted item from the list
      fetchOrders();
    } catch (err) {
      console.error("Order deletion failed:", err);
      // Added more detailed logging for debugging
      console.log("Error response:", err.response);
      console.log("Error request:", err.request);
      console.log("Error message:", err.message);

      if (err.response) {
        alert(
          `❌ Failed to delete order: ${
            err.response.data.message || err.response.statusText
          }`
        );
      } else {
        alert(
          "❌ Failed to delete order. Network error or server unreachable."
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
        <h2>Orders</h2>
        {/* Filters and Sorting Section */}
        <div
          className="filters-container"
          style={{
            marginBottom: "20px",
            display: "flex",
            flexWrap: "wrap",
            gap: "10px",
            alignItems: "center",
          }}
        >
          {/* Status Filter */}
          <select
            value={filterStatus}
            onChange={(e) => {
              setFilterStatus(e.target.value);
              setPage(1); // Reset to first page on filter change
            }}
            style={{
              padding: "8px",
              borderRadius: "4px",
              border: "1px solid #ccc",
            }}
          >
            <option value="">Filter by Status</option>
            {statusOptions.map((status) => (
              <option key={status} value={status}>
                {status}
              </option>
            ))}
          </select>

          {/* Order Type Filter */}
          <select
            value={filterOrderType}
            onChange={(e) => {
              setFilterOrderType(e.target.value);
              setPage(1); // Reset to first page on filter change
            }}
            style={{
              padding: "8px",
              borderRadius: "4px",
              border: "1px solid #ccc",
            }}
          >
            <option value="">Filter by Order Type</option>
            {orderTypeOptions.map((type) => (
              <option key={type} value={type}>
                {type.charAt(0).toUpperCase() + type.slice(1)}{" "}
                {/* Capitalize first letter */}
              </option>
            ))}
          </select>

          {/* Customer ID Filter Input */}
          <input
            type="text"
            placeholder="Customer ID"
            value={filterCustomerId}
            onChange={(e) => setFilterCustomerId(e.target.value)}
            style={{
              padding: "8px",
              borderRadius: "4px",
              border: "1px solid #ccc",
            }}
          />
          {/* Truck ID Filter Input */}
          <input
            type="text"
            placeholder="Truck ID"
            value={filterTruckId}
            onChange={(e) => setFilterTruckId(e.target.value)} // Corrected: This now uses setFilterTruckId
            style={{
              padding: "8px",
              borderRadius: "4px",
              border: "1px solid #ccc",
            }}
          />

          {/* Sort By Selector */}
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value)}
            style={{
              padding: "8px",
              borderRadius: "4px",
              border: "1px solid #ccc",
            }}
          >
            <option value="createdAt">Sort By Date</option>
            <option value="total_price">Sort By Price</option>
            <option value="status">Sort By Status</option>
          </select>
          {/* Order By (Asc/Desc) Selector */}
          <select
            value={orderBy}
            onChange={(e) => setOrderBy(e.target.value)}
            style={{
              padding: "8px",
              borderRadius: "4px",
              border: "1px solid #ccc",
            }}
          >
            <option value="desc">Descending</option>
            <option value="asc">Ascending</option>
          </select>

          {/* Clear Filters Button */}
          <button
            onClick={() => {
              setFilterStatus("");
              setFilterOrderType("");
              setFilterCustomerId("");
              setFilterTruckId("");
              setSortBy("createdAt"); // Reset to default sort
              setOrderBy("desc"); // Reset to default order
              setPage(1); // Always reset to page 1 when clearing filters
            }}
            style={{
              padding: "8px 15px",
              backgroundColor: "#f44336",
              color: "white",
              border: "none",
              borderRadius: "4px",
              cursor: "pointer",
            }}
          >
            Clear Filters
          </button>
        </div>
        {/* Loading and Error Messages */}
        {loading && <p>Loading orders...</p>}
        {error && <p className="error-message">{error}</p>}{" "}
        {/* Error message display */}
        {/* Display Table or "No orders found" */}
        {!loading && !error && orders.length === 0 && (
          <p>No orders found matching your criteria.</p>
        )}
        {!loading && !error && orders.length > 0 && (
          <>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Order ID</th>
                  <th>Customer</th>
                  <th>Truck</th>
                  <th>Items</th>
                  <th>Total Price</th>
                  <th>Order Type</th>
                  <th>Status</th>
                  <th>Order Date</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {orders.map((order) => (
                  <tr key={order._id}>
                    <td>{order._id}</td>
                    {/* Optional chaining (?) is crucial here in case populate fails or data is missing */}
                    <td>
                      {order.customer_id?.F_name} {order.customer_id?.L_name}
                    </td>
                    <td>{order.truck_id?.truck_name}</td>
                    <td>
                      <ul>
                        {/* Ensure 'items' array exists before mapping */}
                        {order.items &&
                          order.items.map((item, index) => (
                            <li key={index}>
                              {item.name} (x{item.quantity}) - $
                              {item.price?.toFixed(2)}
                            </li>
                          ))}
                      </ul>
                    </td>
                    <td>${order.total_price?.toFixed(2)}</td>{" "}
                    {/* Use optional chaining and toFixed for price */}
                    <td>{order.order_type}</td>
                    <td>{order.status}</td>
                    <td>{new Date(order.createdAt).toLocaleString()}</td>{" "}
                    {/* Format date for readability */}
                    <td>
                      <button
                        className="edit-btn"
                        onClick={() => handleEditClick(order)}
                      >
                        Edit Status
                      </button>
                      <button
                        className="delete-btn"
                        onClick={() => handleDelete(order._id)}
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* Pagination Controls */}
            <div
              className="pagination-controls"
              style={{
                display: "flex",
                justifyContent: "center",
                marginTop: "20px",
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
                Page {page} of {totalPages}
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
              <select
                value={limit}
                onChange={(e) => {
                  setLimit(parseInt(e.target.value));
                  setPage(1);
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
          </>
        )}
        {/* Edit Order Status Form (Modal-like overlay) */}
        {editingOrder && (
          <div
            className="edit-order-form-overlay"
            style={{
              position: "fixed",
              top: 0,
              left: 0,
              width: "100%",
              height: "100%",
              backgroundColor: "rgba(0, 0, 0, 0.5)", // Dark overlay
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
                minWidth: "300px",
                maxWidth: "500px",
                width: "90%",
              }}
            >
              <h3>Edit Order Status for Order ID: {editingOrder}</h3>
              <form onSubmit={(e) => e.preventDefault()}>
                <label
                  htmlFor="orderStatus"
                  style={{
                    display: "block",
                    marginBottom: "8px",
                    fontWeight: "bold",
                  }}
                >
                  Status:
                </label>
                <select
                  name="status"
                  id="orderStatus"
                  value={formData.status || ""}
                  onChange={handleInputChange}
                  style={{
                    width: "100%",
                    padding: "10px",
                    marginBottom: "15px",
                    borderRadius: "4px",
                    border: "1px solid #ccc",
                    fontSize: "16px",
                  }}
                >
                  {statusOptions.map((status) => (
                    <option key={status} value={status}>
                      {status}
                    </option>
                  ))}
                </select>
                <div
                  className="form-buttons"
                  style={{
                    display: "flex",
                    justifyContent: "flex-end",
                    gap: "10px",
                  }}
                >
                  <button
                    type="button"
                    onClick={handleSaveEdit}
                    style={{
                      padding: "10px 20px",
                      backgroundColor: "#28a745",
                      color: "white",
                      border: "none",
                      borderRadius: "4px",
                      cursor: "pointer",
                      fontSize: "16px",
                    }}
                  >
                    Save Changes
                  </button>
                  <button
                    type="button"
                    onClick={handleCancelEdit}
                    style={{
                      padding: "10px 20px",
                      backgroundColor: "#6c757d",
                      color: "white",
                      border: "none",
                      borderRadius: "4px",
                      cursor: "pointer",
                      fontSize: "16px",
                    }}
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

export default OrdersPage;
