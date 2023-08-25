<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DatabaseMetaData" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="oracle.jdbc.driver.OracleDriver" %>
<%@ page import="java.util.Locale" %>
<%

//String strJdbcUrl = "jdbc:oracle:oci8:@<tns alias>";
String strJdbcUrl = "jdbc:oracle:thin:@<hostname>:<port>:<sid>";
String strUsername = "user01";
String strPassword = strUsername;

InitialContext ic = null;
DataSource ds01 = null;
Connection conn01 = null;
DatabaseMetaData dbmd01 = null;
Statement stmt01 = null;
Statement stmt02 = null;
PreparedStatement pstmt02 = null;
ResultSet rs01 = null;
ResultSet rs02 = null;
ResultSet rs03 = null;


%>
JVM Properities
<OL>
<LI>java.specification.name=<%= System.getProperty("java.specification.name") %></LI>
<LI>java.specification.version=<%= System.getProperty("java.specification.version") %></LI>
<LI>java.vm.name=<%= System.getProperty("java.vm.name") %></LI>
<LI>java.vm.version=<%= System.getProperty("java.vm.version") %></LI>
<LI>java.vm.vendor=<%= System.getProperty("java.vm.vendor") %></LI>
<LI>os.name=<%= System.getProperty("os.name") %></LI>
<LI>os.version=<%= System.getProperty("os.version") %></LI>
<LI>os.arch=<%= System.getProperty("os.arch") %></LI>
<LI>java.home=<%= System.getProperty("java.home") %></LI>
<LI>java.class.path</LI>
<OL><%
	String[] asClassPath = (System.getProperty("java.class.path")).split(System.getProperty("path.separator"));
	for (int i = 0; i < asClassPath.length; i++) {
		out.print("<LI>");
		out.print(asClassPath[i]);
		out.println("</LI>");
	}
%></OL>
<LI>java.library.path</LI>
<OL><%
	String[] asLibPath = (System.getProperty("java.library.path")).split(System.getProperty("path.separator"));
	for (int i = 0; i < asLibPath.length; i++) {
		out.print("<LI>");
		out.print(asLibPath[i]);
		out.println("</LI>");
	}
%></OL>
<LI>user.name=<%= System.getProperty("user.name") %></LI>
<LI>user.home=<%= System.getProperty("user.home") %></LI>
<LI>user.dir=<%= System.getProperty("user.dir") %></LI>
</OL>
Default Locale
<OL>
Language is set to <%= Locale.getDefault().getLanguage() %></LI>
</OL>

<%
/*

try {
	ic = new InitialContext();
	ds01 = (DataSource)ic.lookup("java:comp/env/jdbc/OracleCoreDS");
} catch (NamingException e) {
	out.print(e.toString());
}
*/

try {
	// conn01 = ds01.getConnection();
	Class.forName("oracle.jdbc.driver.OracleDriver");
	conn01 = DriverManager.getConnection(strJdbcUrl, strUsername, strPassword);
	// conn01.setAutoCommit(false);

	%><p/>JDBC Connection String = <%= strJdbcUrl %><p/><%

	dbmd01 = conn01.getMetaData();
%>
JDBC Driver and RDBMS information
<OL>
<LI>Driver Name: <%= dbmd01.getDriverName() %></LI>
<LI>Driver Version: <%= dbmd01.getDriverVersion() %></LI>
<LI>Database Product Name: <%= dbmd01.getDatabaseProductName() %></LI>
<LI>Database Product Version: <%= dbmd01.getDatabaseProductVersion() %></LI>
</OL>
<%
	stmt01 = conn01.createStatement();
%>Database
<%
	rs01 = stmt01.executeQuery("SELECT parameter, value FROM v$nls_parameters WHERE parameter IN ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET')");
%><OL><%
	while (rs01.next()) {
		%><LI><%= rs01.getString(1) %> = <%= rs01.getString(2) %></LI><%
	}
%></OL><%

} catch (SQLException e) {
	out.print(e.toString());
	e.printStackTrace();
} finally {
	if ( rs01 != null ) {
		try { rs01.close(); } catch (SQLException e) { e.printStackTrace(); }
	}
	if ( rs02 != null ) {
		try { rs02.close(); } catch (SQLException e) { e.printStackTrace(); }
	}
	if ( rs03 != null ) {
		try { rs03.close(); } catch (SQLException e) { e.printStackTrace(); }
	}
	if ( stmt01 != null ) {
		try { stmt01.close(); } catch (SQLException e) { e.printStackTrace(); }
	}
	if ( stmt02 != null ) {
		try { stmt02.close(); } catch (SQLException e) { e.printStackTrace(); }
	}
	if ( pstmt02 != null ) {
		try { pstmt02.close(); } catch (SQLException e) { e.printStackTrace(); }
	}
	if ( conn01 != null ) {
		try { conn01.close(); } catch (SQLException e) { e.printStackTrace(); }
	}
}

%>
