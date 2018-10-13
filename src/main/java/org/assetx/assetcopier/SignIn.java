package org.assetx.assetcopier;

import javax.servlet.RequestDispatcher;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(
        name = "SignInServlet",
        urlPatterns = {"/sign_in/*"}
)
public class SignIn extends HttpServlet{

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp){

        //Controllo se il protocollo è https
        Utils.checkForHttpsProtocol(req, resp);

        try {
            RequestDispatcher view = req.getRequestDispatcher("sign_in.jsp");
            view.forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp){
        doGet(req,resp);
    }

}