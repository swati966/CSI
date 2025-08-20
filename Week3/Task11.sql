--Task 11
SELECT 
    s.Name
FROM 
    Students s
    JOIN Friends f ON s.ID = f.ID
    JOIN Packages p_student ON s.ID = p_student.ID
    JOIN Packages p_friend ON f.Friend_ID = p_friend.ID
WHERE 
    p_friend.Salary > p_student.Salary
ORDER BY 
    p_friend.Salary;