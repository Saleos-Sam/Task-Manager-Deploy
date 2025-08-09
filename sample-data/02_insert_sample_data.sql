-- Task Manager Sample Data Population Script
-- This script populates the database with comprehensive sample data
-- 
-- ✅ UPDATED FOR 2025 and beyond - Uses dynamic dates relative to CURRENT_DATE
-- ✅ Creates realistic scenarios with overdue, current, and future tasks
-- ✅ Works for any year - dates are calculated dynamically
--
-- Scenarios included:
-- - Overdue tasks (past due dates)
-- - Tasks due soon (within days/weeks)  
-- - Future tasks (weeks/months ahead)
-- - Completed tasks (with proper completion dates)

-- Clear existing data (optional - uncomment if needed)
-- DELETE FROM tasks;

-- Insert sample tasks with various statuses, priorities, and categories
INSERT INTO tasks (title, description, due_date, status, priority, category, assigned_to, estimated_hours, created_by, created_at, updated_at) VALUES

-- Development Tasks
('Implement User Authentication', 'Add JWT-based authentication system with role-based access control', CURRENT_DATE + INTERVAL '15 days', 'IN_PROGRESS', 'HIGH', 'Security', 'john.doe@company.com', 20, 'manager@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Build REST API Endpoints', 'Create comprehensive REST API for task management with full CRUD operations', CURRENT_DATE + INTERVAL '10 days', 'TODO', 'HIGH', 'Development', 'jane.smith@company.com', 16, 'lead@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Frontend Integration', 'Integrate React frontend with the new API endpoints', CURRENT_DATE + INTERVAL '20 days', 'TODO', 'MEDIUM', 'Frontend', 'frontend.dev@company.com', 24, 'manager@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Database Optimization', 'Optimize database queries and add proper indexing for better performance', CURRENT_DATE + INTERVAL '8 days', 'IN_PROGRESS', 'MEDIUM', 'Database', 'db.admin@company.com', 12, 'architect@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Mobile App Development', 'Develop mobile application for iOS and Android platforms', CURRENT_DATE + INTERVAL '45 days', 'TODO', 'LOW', 'Mobile', 'mobile.dev@company.com', 80, 'product@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Testing Tasks
('Unit Test Coverage', 'Increase unit test coverage to 95% for all critical components', CURRENT_DATE + INTERVAL '12 days', 'TODO', 'MEDIUM', 'Testing', 'qa.engineer@company.com', 14, 'qa.lead@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Performance Testing', 'Conduct load testing and stress testing for the application', CURRENT_DATE + INTERVAL '18 days', 'ON_HOLD', 'LOW', 'Testing', 'perf.tester@company.com', 16, 'qa.lead@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Integration Testing', 'Set up automated integration tests for all API endpoints', CURRENT_DATE + INTERVAL '14 days', 'TODO', 'MEDIUM', 'Testing', 'qa.engineer@company.com', 10, 'qa.lead@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Bug Fixes (some overdue to create realistic scenarios)
('Fix Memory Leak Issue', 'Resolve memory leak in the background task processor', CURRENT_DATE - INTERVAL '5 days', 'TODO', 'URGENT', 'Bug Fix', 'senior.dev@company.com', 8, 'support@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Resolve Database Timeout', 'Fix intermittent database connection timeout errors', CURRENT_DATE - INTERVAL '2 days', 'TODO', 'HIGH', 'Bug Fix', 'db.admin@company.com', 6, 'support@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('UI Responsiveness Bug', 'Fix responsive design issues on mobile devices', CURRENT_DATE + INTERVAL '5 days', 'IN_PROGRESS', 'MEDIUM', 'Bug Fix', 'frontend.dev@company.com', 4, 'ux.designer@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Documentation Tasks
('API Documentation', 'Write comprehensive API documentation with examples and use cases', CURRENT_DATE + INTERVAL '8 days', 'IN_PROGRESS', 'MEDIUM', 'Documentation', 'tech.writer@company.com', 12, 'manager@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('User Manual', 'Create user manual and help documentation for end users', CURRENT_DATE + INTERVAL '22 days', 'TODO', 'LOW', 'Documentation', 'tech.writer@company.com', 20, 'product@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Developer Guide', 'Write developer setup guide and contribution guidelines', CURRENT_DATE + INTERVAL '16 days', 'TODO', 'MEDIUM', 'Documentation', 'senior.dev@company.com', 8, 'lead@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- DevOps Tasks
('CI/CD Pipeline Setup', 'Configure automated testing and deployment pipeline with Jenkins', CURRENT_DATE + INTERVAL '10 days', 'TODO', 'HIGH', 'DevOps', 'devops.engineer@company.com', 18, 'cto@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker Containerization', 'Containerize the application and create Docker compose setup', CURRENT_DATE + INTERVAL '12 days', 'TODO', 'MEDIUM', 'DevOps', 'devops.engineer@company.com', 10, 'architect@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Monitoring Setup', 'Implement application monitoring with Prometheus and Grafana', CURRENT_DATE + INTERVAL '25 days', 'TODO', 'MEDIUM', 'DevOps', 'sre.engineer@company.com', 14, 'devops.lead@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Security Tasks
('Security Audit', 'Conduct comprehensive security audit and penetration testing', CURRENT_DATE + INTERVAL '28 days', 'TODO', 'HIGH', 'Security', 'security@company.com', 24, 'ciso@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Data Encryption', 'Implement end-to-end encryption for sensitive data', CURRENT_DATE + INTERVAL '20 days', 'TODO', 'HIGH', 'Security', 'security.dev@company.com', 16, 'security@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Completed Tasks (with past due dates)
('Database Schema Design', 'Design and implement the initial database schema', CURRENT_DATE - INTERVAL '15 days', 'COMPLETED', 'HIGH', 'Database', 'db.admin@company.com', 16, 'architect@company.com', CURRENT_TIMESTAMP - INTERVAL '25 days', CURRENT_TIMESTAMP - INTERVAL '20 days'),

('Project Setup', 'Initialize project structure and configure build tools', CURRENT_DATE - INTERVAL '20 days', 'COMPLETED', 'MEDIUM', 'Setup', 'lead@company.com', 8, 'manager@company.com', CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '28 days'),

('Requirements Analysis', 'Analyze and document all functional and non-functional requirements', CURRENT_DATE - INTERVAL '22 days', 'COMPLETED', 'HIGH', 'Analysis', 'analyst@company.com', 20, 'product@company.com', CURRENT_TIMESTAMP - INTERVAL '32 days', CURRENT_TIMESTAMP - INTERVAL '30 days'),

-- Overdue Tasks (intentionally past due for testing)
('Code Review Process', 'Establish code review guidelines and implement automated checks', CURRENT_DATE - INTERVAL '10 days', 'TODO', 'MEDIUM', 'Process', 'senior.dev@company.com', 6, 'lead@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Legacy Code Refactoring', 'Refactor legacy codebase to improve maintainability', CURRENT_DATE - INTERVAL '8 days', 'IN_PROGRESS', 'LOW', 'Maintenance', 'senior.dev@company.com', 32, 'architect@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Research Tasks
('Technology Research', 'Research new technologies for next generation architecture', CURRENT_DATE + INTERVAL '60 days', 'TODO', 'LOW', 'Research', 'architect@company.com', 40, 'cto@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Competitor Analysis', 'Analyze competitor products and identify improvement opportunities', CURRENT_DATE + INTERVAL '30 days', 'TODO', 'MEDIUM', 'Research', 'analyst@company.com', 16, 'product@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Maintenance Tasks
('Dependency Updates', 'Update all project dependencies to latest stable versions', CURRENT_DATE + INTERVAL '5 days', 'TODO', 'LOW', 'Maintenance', 'john.doe@company.com', 4, 'lead@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Log Cleanup', 'Clean up old log files and implement log rotation', CURRENT_DATE + INTERVAL '8 days', 'TODO', 'LOW', 'Maintenance', 'devops.engineer@company.com', 2, 'sre.engineer@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- UI/UX Tasks
('User Interface Redesign', 'Redesign user interface based on user feedback and usability testing', CURRENT_DATE + INTERVAL '40 days', 'TODO', 'MEDIUM', 'Design', 'ux.designer@company.com', 30, 'design.lead@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Accessibility Improvements', 'Implement accessibility features to comply with WCAG 2.1 standards', CURRENT_DATE + INTERVAL '26 days', 'TODO', 'MEDIUM', 'Accessibility', 'frontend.dev@company.com', 12, 'ux.designer@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Training Tasks
('Team Training', 'Conduct training sessions on new tools and technologies', CURRENT_DATE + INTERVAL '15 days', 'TODO', 'LOW', 'Training', 'senior.dev@company.com', 8, 'manager@company.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Update completion dates for completed tasks
UPDATE tasks 
SET completion_date = updated_at 
WHERE status = 'COMPLETED';

-- Verify the data
SELECT 
    status,
    priority,
    category,
    COUNT(*) as task_count
FROM tasks 
GROUP BY status, priority, category
ORDER BY status, priority, category;

-- Show sample of inserted data
SELECT 
    title,
    status,
    priority,
    due_date,
    assigned_to
FROM tasks 
ORDER BY due_date 
LIMIT 10;
