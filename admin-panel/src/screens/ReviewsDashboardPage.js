import React, { useEffect, useState, useCallback } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar";
import "../styles/table.css"; // Reusing your table styles
import { FaStar, FaTrashAlt } from "react-icons/fa"; // For stars and delete icon

const ReviewsDashboardPage = () => {
  const [activeTab, setActiveTab] = useState("menuItem"); // "menuItem" or "truck"

  // State for Menu Item Reviews
  const [menuItemReviews, setMenuItemReviews] = useState([]);
  const [menuItemLoading, setMenuItemLoading] = useState(true);
  const [menuItemError, setMenuItemError] = useState(null);
  const [menuItemPage, setMenuItemPage] = useState(1);
  const [menuItemLimit, setMenuItemLimit] = useState(10);
  const [menuItemTotalPages, setMenuItemTotalPages] = useState(1);
  const [menuItemTotalItems, setMenuItemTotalItems] = useState(0);
  const [menuItemSentimentFilter, setMenuItemSentimentFilter] = useState("");
  const [menuItemRatingFilter, setMenuItemRatingFilter] = useState("");

  // State for Truck Reviews
  const [truckReviews, setTruckReviews] = useState([]);
  const [truckLoading, setTruckLoading] = useState(true);
  const [truckError, setTruckError] = useState(null);
  const [truckPage, setTruckPage] = useState(1);
  const [truckLimit, setTruckLimit] = useState(10);
  const [truckTotalPages, setTruckTotalPages] = useState(1);
  const [truckTotalItems, setTruckTotalItems] = useState(0);
  const [truckSentimentFilter, setTruckSentimentFilter] = useState("");
  const [truckRatingFilter, setTruckRatingFilter] = useState("");

  // --- Fetching Logic for Menu Item Reviews ---
  const fetchMenuItemReviews = useCallback(async () => {
    setMenuItemLoading(true);
    setMenuItemError(null);
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        setMenuItemError("Authentication token not found. Please log in.");
        setMenuItemLoading(false);
        return;
      }

      const params = { page: menuItemPage, limit: menuItemLimit };
      if (menuItemSentimentFilter) params.sentiment = menuItemSentimentFilter;
      if (menuItemRatingFilter) params.rating = menuItemRatingFilter;

      const res = await axios.get(
        "http://localhost:5000/api/reviews/admin/menu-items",
        {
          headers: { Authorization: `Bearer ${token}` },
          params: params,
        }
      );
      setMenuItemReviews(res.data.reviews);
      setMenuItemTotalPages(res.data.totalPages);
      setMenuItemTotalItems(res.data.totalItems);
    } catch (err) {
      console.error("Error fetching menu item reviews:", err);
      setMenuItemError(
        `Failed to fetch menu item reviews: ${
          err.response?.data?.message || err.message
        }`
      );
    } finally {
      setMenuItemLoading(false);
    }
  }, [
    menuItemPage,
    menuItemLimit,
    menuItemSentimentFilter,
    menuItemRatingFilter,
  ]);

  // --- Fetching Logic for Truck Reviews ---
  const fetchTruckReviews = useCallback(async () => {
    setTruckLoading(true);
    setTruckError(null);
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        setTruckError("Authentication token not found. Please log in.");
        setTruckLoading(false);
        return;
      }

      const params = { page: truckPage, limit: truckLimit };
      if (truckSentimentFilter) params.sentiment = truckSentimentFilter;
      if (truckRatingFilter) params.rating = truckRatingFilter;

      const res = await axios.get(
        "http://localhost:5000/api/reviews/admin/trucks",
        {
          headers: { Authorization: `Bearer ${token}` },
          params: params,
        }
      );
      setTruckReviews(res.data.reviews);
      setTruckTotalPages(res.data.totalPages);
      setTruckTotalItems(res.data.totalItems);
    } catch (err) {
      console.error("Error fetching truck reviews:", err);
      setTruckError(
        `Failed to fetch truck reviews: ${
          err.response?.data?.message || err.message
        }`
      );
    } finally {
      setTruckLoading(false);
    }
  }, [truckPage, truckLimit, truckSentimentFilter, truckRatingFilter]);

  // Effect to fetch data when tab changes or dependencies update
  useEffect(() => {
    if (activeTab === "menuItem") {
      fetchMenuItemReviews();
    } else {
      fetchTruckReviews();
    }
  }, [activeTab, fetchMenuItemReviews, fetchTruckReviews]); // Only re-run if activeTab or fetch functions change

  // --- Deletion Handlers ---
  const handleDeleteMenuItemReview = async (reviewId) => {
    const confirmDelete = window.confirm(
      "Are you sure you want to delete this menu item review? This action cannot be undone."
    );
    if (!confirmDelete) return;

    try {
      const token = localStorage.getItem("token");
      await axios.delete(
        `http://localhost:5000/api/reviews/admin/menu-items/${reviewId}`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      alert("✅ Menu item review deleted successfully!");
      fetchMenuItemReviews(); // Re-fetch to update list
    } catch (err) {
      console.error("Error deleting menu item review:", err);
      alert(
        `❌ Failed to delete review: ${
          err.response?.data?.message || err.message
        }`
      );
    }
  };

  const handleDeleteTruckReview = async (reviewId) => {
    const confirmDelete = window.confirm(
      "Are you sure you want to delete this truck review? This action cannot be undone."
    );
    if (!confirmDelete) return;

    try {
      const token = localStorage.getItem("token");
      await axios.delete(
        `http://localhost:5000/api/reviews/admin/trucks/${reviewId}`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      alert("✅ Truck review deleted successfully!");
      fetchTruckReviews(); // Re-fetch to update list
    } catch (err) {
      console.error("Error deleting truck review:", err);
      alert(
        `❌ Failed to delete review: ${
          err.response?.data?.message || err.message
        }`
      );
    }
  };

  // --- Helper for rendering stars ---
  const renderStars = (rating) => {
    return (
      <div style={{ display: "flex" }}>
        {[...Array(5)].map((_, i) => (
          <FaStar
            key={i}
            color={i < rating ? "#FFD700" : "#e4e5e9"}
            size={18}
          />
        ))}
      </div>
    );
  };

  // --- Pagination Controls Component (reusable) ---
  const PaginationControls = ({
    currentPage,
    totalPages,
    totalItems,
    onPrevPage,
    onNextPage,
    limit,
    onLimitChange,
  }) => (
    <div
      className="pagination-controls"
      style={{
        display: "flex",
        justifyContent: "center",
        marginTop: "20px",
        gap: "10px",
        alignItems: "center",
      }}
    >
      <button
        onClick={onPrevPage}
        disabled={currentPage === 1}
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
        Page {currentPage} of {totalPages} ({totalItems} items)
      </span>
      <button
        onClick={onNextPage}
        disabled={currentPage === totalPages}
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
        onChange={onLimitChange}
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
  );

  return (
    <div className="dashboard-container">
      <Sidebar />
      <div className="main-panel">
        <h2 style={{ marginBottom: "20px" }}>🌟 Customer Reviews (Admin)</h2>

        {/* Tab Navigation */}
        <div
          className="tab-navigation"
          style={{ marginBottom: "20px", borderBottom: "1px solid #eee" }}
        >
          <button
            onClick={() => setActiveTab("menuItem")}
            style={{
              padding: "10px 20px",
              border: "none",
              backgroundColor: activeTab === "menuItem" ? "#007bff" : "#f0f0f0",
              color: activeTab === "menuItem" ? "white" : "black",
              cursor: "pointer",
              borderTopLeftRadius: "8px",
              borderTopRightRadius: "8px",
              marginRight: "5px",
              fontWeight: activeTab === "menuItem" ? "bold" : "normal",
            }}
          >
            Menu Item Reviews
          </button>
          <button
            onClick={() => setActiveTab("truck")}
            style={{
              padding: "10px 20px",
              border: "none",
              backgroundColor: activeTab === "truck" ? "#007bff" : "#f0f0f0",
              color: activeTab === "truck" ? "white" : "black",
              cursor: "pointer",
              borderTopLeftRadius: "8px",
              borderTopRightRadius: "8px",
              fontWeight: activeTab === "truck" ? "bold" : "normal",
            }}
          >
            Truck Reviews
          </button>
        </div>

        {/* Conditional Rendering based on Active Tab */}
        {activeTab === "menuItem" && (
          <div className="menu-item-reviews-section">
            <h3>Menu Item Reviews</h3>
            {/* Filters remain the same as you provided */}
            <div
              style={{
                display: "flex",
                gap: "15px",
                marginBottom: "20px",
                alignItems: "center",
              }}
            >
              <label>
                Sentiment:
                <select
                  value={menuItemSentimentFilter}
                  onChange={(e) => {
                    setMenuItemSentimentFilter(e.target.value);
                    setMenuItemPage(1);
                  }}
                  style={{ marginLeft: "5px" }}
                >
                  <option value="">All</option>
                  <option value="positive">Positive</option>
                  <option value="neutral">Neutral</option>
                  <option value="negative">Negative</option>
                </select>
              </label>
              <label>
                Rating:
                <select
                  value={menuItemRatingFilter}
                  onChange={(e) => {
                    setMenuItemRatingFilter(e.target.value);
                    setMenuItemPage(1);
                  }}
                  style={{ marginLeft: "5px" }}
                >
                  <option value="">All</option>
                  {[1, 2, 3, 4, 5].map((r) => (
                    <option key={r} value={r}>
                      {r} Star{r > 1 && "s"}
                    </option>
                  ))}
                </select>
              </label>
            </div>

            {menuItemLoading && <p>Loading menu item reviews...</p>}
            {menuItemError && <p className="error-message">{menuItemError}</p>}
            {!menuItemLoading &&
              !menuItemError &&
              menuItemReviews.length === 0 && (
                <p>No menu item reviews found matching your criteria.</p>
              )}

            {!menuItemLoading &&
              !menuItemError &&
              menuItemReviews.length > 0 && (
                <>
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>Item Name</th>
                        <th>Truck Name</th>
                        <th>Customer</th>
                        <th>Rating</th>
                        <th>Comment</th>
                        <th>Sentiment</th>
                        <th>Date</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {menuItemReviews.map((review) => (
                        <tr key={review._id}>
                          {/* EDIT 1: Corrected from 'name' to 'item_name' */}
                          <td>{review.menu_item_id?.name || "N/A"}</td>
                          {/* EDIT 2: Corrected access for truck_name */}
                          <td>
                            {review.menu_item_id?.truck_id?.truck_name || "N/A"}
                          </td>
                          <td>
                            {review.customer_id?.F_name
                              ? `${review.customer_id.F_name} ${review.customer_id.L_name}`
                              : review.customer_id?._id || "Unknown"}
                          </td>
                          <td>{renderStars(review.rating)}</td>
                          <td>{review.comment || "—"}</td>
                          <td>
                            <span
                              className={`sentiment-${review.sentiment}`}
                              style={{
                                padding: "4px 8px",
                                borderRadius: "4px",
                                color: "white",
                                fontWeight: "bold",
                                backgroundColor:
                                  review.sentiment === "positive"
                                    ? "#28a745"
                                    : review.sentiment === "negative"
                                    ? "#dc3545"
                                    : "#ffc107",
                              }}
                            >
                              {review.sentiment}
                            </span>
                          </td>
                          {/* EDIT 4: Ensured proper date formatting with fallback */}
                          <td>
                            {review.createdAt
                              ? new Date(review.createdAt).toLocaleDateString()
                              : "N/A"}
                          </td>
                          <td>
                            <button
                              className="delete-btn"
                              onClick={() =>
                                handleDeleteMenuItemReview(review._id)
                              }
                            >
                              <FaTrashAlt />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                  <PaginationControls
                    currentPage={menuItemPage}
                    totalPages={menuItemTotalPages}
                    totalItems={menuItemTotalItems}
                    onPrevPage={() => setMenuItemPage(menuItemPage - 1)}
                    onNextPage={() => setMenuItemPage(menuItemPage + 1)}
                    limit={menuItemLimit}
                    onLimitChange={(e) => {
                      setMenuItemLimit(parseInt(e.target.value));
                      setMenuItemPage(1);
                    }}
                  />
                </>
              )}
          </div>
        )}

        {/* Truck Reviews Section */}
        {activeTab === "truck" && (
          <div className="truck-reviews-section">
            <h3>Truck Reviews</h3>
            {/* Filters remain the same as you provided */}
            <div
              style={{
                display: "flex",
                gap: "15px",
                marginBottom: "20px",
                alignItems: "center",
              }}
            >
              <label>
                Sentiment:
                <select
                  value={truckSentimentFilter}
                  onChange={(e) => {
                    setTruckSentimentFilter(e.target.value);
                    setTruckPage(1);
                  }}
                  style={{ marginLeft: "5px" }}
                >
                  <option value="">All</option>
                  <option value="positive">Positive</option>
                  <option value="neutral">Neutral</option>
                  <option value="negative">Negative</option>
                </select>
              </label>
              <label>
                Rating:
                <select
                  value={truckRatingFilter}
                  onChange={(e) => {
                    setTruckRatingFilter(e.target.value);
                    setTruckPage(1);
                  }}
                  style={{ marginLeft: "5px" }}
                >
                  <option value="">All</option>
                  {[1, 2, 3, 4, 5].map((r) => (
                    <option key={r} value={r}>
                      {r} Star{r > 1 && "s"}
                    </option>
                  ))}
                </select>
              </label>
            </div>

            {truckLoading && <p>Loading truck reviews...</p>}
            {truckError && <p className="error-message">{truckError}</p>}
            {!truckLoading && !truckError && truckReviews.length === 0 && (
              <p>No truck reviews found matching your criteria.</p>
            )}

            {!truckLoading && !truckError && truckReviews.length > 0 && (
              <>
                <table className="admin-table">
                  <thead>
                    <tr>
                      <th>Truck Name</th>
                      <th>Customer</th>
                      <th>Rating</th>
                      <th>Comment</th>
                      <th>Sentiment</th>
                      <th>Date</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {truckReviews.map((review) => (
                      <tr key={review._id}>
                        {/* EDIT 3: Corrected access for truck_name */}
                        <td>{review.truck_id?.truck_name || "N/A"}</td>
                        <td>
                          {review.customer_id?.F_name
                            ? `${review.customer_id.F_name} ${review.customer_id.L_name}`
                            : review.customer_id?._id || "Unknown"}
                        </td>
                        <td>{renderStars(review.rating)}</td>
                        <td>{review.comment || "—"}</td>
                        <td>
                          <span
                            className={`sentiment-${review.sentiment}`}
                            style={{
                              padding: "4px 8px",
                              borderRadius: "4px",
                              color: "white",
                              fontWeight: "bold",
                              backgroundColor:
                                review.sentiment === "positive"
                                  ? "#28a745"
                                  : review.sentiment === "negative"
                                  ? "#dc3545"
                                  : "#ffc107",
                            }}
                          >
                            {review.sentiment}
                          </span>
                        </td>
                        {/* EDIT 4: Ensured proper date formatting with fallback */}
                        <td>
                          {review.createdAt
                            ? new Date(review.createdAt).toLocaleDateString()
                            : "N/A"}
                        </td>
                        <td>
                          <button
                            className="delete-btn"
                            onClick={() => handleDeleteTruckReview(review._id)}
                          >
                            <FaTrashAlt />
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                <PaginationControls
                  currentPage={truckPage}
                  totalPages={truckTotalPages}
                  totalItems={truckTotalItems}
                  onPrevPage={() => setTruckPage(truckPage - 1)}
                  onNextPage={() => setTruckPage(truckPage + 1)}
                  limit={truckLimit}
                  onLimitChange={(e) => {
                    setTruckLimit(parseInt(e.target.value));
                    setTruckPage(1);
                  }}
                />
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default ReviewsDashboardPage;