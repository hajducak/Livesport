# Reference Exercise for Knowledge Testing and Candidate Development  

The goal is to implement a simple application for searching entities—competitions, teams, and players—using the **Livesport Search Service API**.  

---

## **Functional Requirements**  
- The application will have **two screens**: a results list and a detail view.  
- The **results list** should include:  
  - A title (e.g., *Results*)  
  - A search field  
  - A search button  
  - A list of results  
- The search must support **filtering by entity type** (based on API parameters):  
  - **All types** – IDs: `1,2,3,4`  
  - **Competitions only** – ID: `1`  
  - **Participants only** – IDs: `2,3,4`  
- The app should properly indicate **data loading status** (e.g., loading spinner).  
- In case of any errors (e.g., no internet, server failure), an **alert** should appear with an appropriate message and a **retry** button.  
- Each result item must display at least:  
  - **Entity name** (e.g., *Arsenal FC, Roger Federer*).  
  - **Logo/photo** (or a placeholder if missing).  
- The results list should be **grouped by sport** into sections, each with a **sport title header**.  
- Selecting a result should navigate to the **detail view**.  
- The **detail view** should display:  
  - The entity's **title**  
  - A **larger photo/logo/placeholder**  
  - The **country** of the competition/team/player  
  - Any other relevant available information  

---

## **Technical Requirements**  
- **SwiftUI** for the user interface (color scheme and styling are up to you).  
- **The Composable Architecture (TCA)**: [GitHub Repository](https://github.com/pointfreeco/swift-composable-architecture).  
- Use **Combine** or **async/await** for data handling.  
- Support for **iOS 15+**.  
- Developed using the latest **stable Xcode**.  
- **Minimum test coverage** (unit tests required for):  
  - **Networking**  
  - **TCA**  
  - **Services**  
- Use **Git** and commit work **progressively and logically**.    
- Third-party libraries are allowed but should be used **only if necessary**. Use **SPM (Swift Package Manager)** exclusively.  

---

## **Livesport Search Service API**  
### **Endpoint**  
🔗 [https://s.livesport.services/api/v2/search](https://s.livesport.services/api/v2/search)  
