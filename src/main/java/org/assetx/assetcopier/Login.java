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
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Base64;

@WebServlet(
        name = "LoginServlet",
        urlPatterns = {"/login/*"}
)
public class Login extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp){

        //Controllo se il protocollo è https
        Utils.checkForHttpsProtocol(req, resp);

        //Reindirizzo al client web
        try {
            RequestDispatcher view = req.getRequestDispatcher("login.jsp");
            view.forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp){

        //Controllo se il protocollo è https
        Utils.checkForHttpsProtocol(req, resp);


        // path protocol
        String pathStirng = req.getPathInfo();
        if (pathStirng != null) {
            pathStirng = pathStirng.substring(1);
            String patList[] = pathStirng.split("/");
            for (String path : patList)
                System.out.println(path);
            if (patList.length > 0) {
                if (patList[0].equals("api")) {
                    //Sono nella api
                    assert patList.length > 1;
                    if (patList[1].equals("authuser")) {
                        // Devo autenticare l'utente
                        // Ricavo i parametri
                        try {
                            JSONObject postParams = new JSONObject(Utils.readFrominputStram(req.getInputStream()));
                            String email = postParams.getString("email");
                            String password = postParams.getString("password");
                            // Eseguo l'autenticazione
                            int authRes = authenticateUser(null, email, password);
                            System.out.println(authRes);
                            apiProduceOutput(resp, authRes);
                        } catch (JSONException | IOException | SQLException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }else {
            doGet(req, resp);
        }
    }

    public static void apiProduceOutput(HttpServletResponse resp, int authResult) throws JSONException, IOException {
        JSONObject responseJson = new JSONObject();
        if (authResult == 0) {
            responseJson.put("action", "complete");
        }else {
            responseJson.put("action", "failed");
            responseJson.put("error", authResult);
        }
        OutputStream outputStream = resp.getOutputStream();
        outputStream.write(responseJson.toString().getBytes());
        outputStream.flush();
        outputStream.close();
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

        boolean passwordFounded = false;
        boolean attivato = false;

        User user = getUser(connection, email);

        if (user != null) {
            //Controllo corrispondenze
            if (user.password.equals(password))
                passwordFounded = true;
            if (passwordFounded && user.email_active == 1)
                attivato = true;
            //Genero output
            if (!passwordFounded)
                return 2;
            if (!attivato)
                return 3;
            return 0;
        }else
            return 1;
    }

    public static User getUser(Connection connection, String email) {
        if (connection == null)
            connection = SqlUtils.getConnectionHeroku();

        //Faccio una chiamata al db
        Statement statement;
        String query;

        query = "SELECT * FROM users WHERE email='"+email+"';";
        try{
            statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(query);
            User user = null;
            if(resultSet.next()) {
                user = new User();
                user.name = resultSet.getString("name");
                user.surname = resultSet.getString("surname");
                user.email = resultSet.getString("email");
                user.password = resultSet.getString("password");
                user.account_id = resultSet.getString("account_id");
                user.email_active = resultSet.getInt("email_active");
                user.licence_active = resultSet.getInt("licence_active");
                user.passkey = resultSet.getString("passkey");
                user.chat_id = resultSet.getString("chat_id");
                user.trades_listen = resultSet.getBoolean("trades_listen");
                user.email_readable = resultSet.getString("email_readable");
                user.mt_params = resultSet.getString("mt_params");
            }
            connection.close();
            return user;
        }catch (SQLException sqle){
            sqle.printStackTrace();
        }
        return null;
    }

    public static class User {
        public String name;
        public String surname;
        public String email;
        public String password;
        public String account_id;
        public int email_active;
        public int licence_active;
        public String passkey;
        public String chat_id;
        public boolean trades_listen;
        public String email_readable;
        public String mt_params;
    }

    public static class Mt4Params {

        public String channel;
        public String fixedSize;
        public String multiplerSize;
        public String automaticSize;
        public String risk;
        public String pipStopLossDefault;
        public String minimumSize;
        public String orderValidityTime;
        public String slippage;
        public String assetToEsclude;
        public String suffix;

        public Mt4Params (String mt_params) {
            String[] params = mt_params.split("&");
            try{
                this.channel = base64Decoder(params[0]);
            }catch (Exception e) {
                this.channel = "";
            }
            try{
                this.fixedSize = base64Decoder(params[1]);
            }catch (Exception e) {
                this.fixedSize = "";
            }
            try{
                this.multiplerSize = base64Decoder(params[2]);
            }catch (Exception e) {
                this.multiplerSize = "";
            }
            try{
                this.automaticSize = base64Decoder(params[3]);
            }catch (Exception e) {
                this.automaticSize = "";
            }
            try {
                this.risk = base64Decoder(params[4]);
            }catch (Exception e) {
                this.risk = "";
            }
            try {
                this.pipStopLossDefault = base64Decoder(params[5]);
            }catch (Exception e) {
                this.pipStopLossDefault = "";
            }
            try{
                this.minimumSize = base64Decoder(params[6]);
            }catch (Exception e) {
                this.minimumSize = "";
            }
            try {
                this.orderValidityTime = base64Decoder(params[7]);
            }catch (Exception e) {
                this.orderValidityTime = "";
            }
            try{
                this.slippage = base64Decoder(params[8]);
            }catch (Exception e) {
                this.slippage = "";
            }
            try{
                this.assetToEsclude = base64Decoder(params[9]);
            }catch (Exception e) {
                this.assetToEsclude = "";
            }
            try{
                this.suffix = base64Decoder(params[10]);
            }catch (Exception e) {
                this.suffix = "";
            }
        }
    }

    public static String base64Decoder(String source) {
        return new String(Base64.getDecoder().decode(source));
    }

    public static String base64Encoder(String source) {
        return Base64.getEncoder().encodeToString(source.getBytes());
    }
}