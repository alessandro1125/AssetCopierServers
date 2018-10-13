package org.assetx.assetcopier;

import com.assetx.libraries.utils.SqlUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.mortbay.util.ajax.JSON;

import javax.servlet.RequestDispatcher;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Base64;

@WebServlet(
        name = "LoginServlet",
        urlPatterns = {"/login/*"}
)
public class Login extends HttpServlet{

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp){

        //Controllo se il protocollo è https
        Utils.checkForHttpsProtocol(req, resp);


        // GET path protocol
        String patList[] = req.getPathInfo().split("/");
        if (patList.length > 0) {
            if(patList[0].equals("api")) {
                //Sono nella api
                assert patList.length > 1;
                if (patList[1].equals("authuser")) {
                    // Devo autenticare l'utente
                    // Ricavo i parametri
                    try {
                        JSONObject postParams = new JSONObject(Utils.readFrominputStram(req.getInputStream()));
                        String email =      postParams.getString("email");
                        String password =   postParams.getString("password");
                        // Eseguo l'autenticazione
                        int authRes = authenticateUser(null, email, password);
                        apiProduceOutput(resp, authRes);
                    } catch (JSONException | IOException | SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        }else {
            //Reindirizzo al client web
            try {
                RequestDispatcher view = req.getRequestDispatcher("login.jsp");
                view.forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp){
        doGet(req,resp);
    }

    public static void apiProduceOutput(HttpServletResponse resp, int authResult) throws JSONException, IOException {
        JSONObject responseJson = new JSONObject();
        responseJson.put("action", "failed");
        responseJson.put("error", authResult);
        resp.getOutputStream().write(responseJson.toString().getBytes());
    }

    /**
     *
     * 0 - autenticato
     * 1 - email non trovata
     * 2 - password errata
     * 3 - non attivo
     *
     * @param connection Connection
     * @param email String
     * @param password String
     * @return int
     */
    public static int authenticateUser(Connection connection, String email, String password) throws SQLException {

        if (connection == null)
            connection = SqlUtils.getConnectionHeroku();

        //Faccio una chiamata al db
        Statement statement;
        String query;

        query = "SELECT email,password,email_active FROM users WHERE email='"+email+"'";

        try{
            statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(query);

            boolean emailFounded = false;
            boolean passwordFounded = false;
            boolean attivato = false;
            while (resultSet.next()){
                //Controllo corrispondenze
                if (resultSet.getString("email").equals(email))
                    emailFounded = true;
                if (emailFounded && resultSet.getString("password").equals(password))
                    passwordFounded = true;
                if (emailFounded && passwordFounded && resultSet.getString("email_active").equals("1"))
                    attivato = true;
            }
            connection.close();


            //Genero output
            if (!emailFounded)
                return 1;
            if (!passwordFounded)
                return 2;
            if (!attivato)
                return 3;
            return 0;


        }catch (SQLException sqle){
            sqle.printStackTrace();
            return -1;
        }
    }
}