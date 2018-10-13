package org.assetx.assetcopier;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;

import static com.google.common.net.HttpHeaders.X_FORWARDED_PROTO;

/**
 * Utils class for AssetMax project
 * @author Alessandro Giordano
 */
public class Utils {

    /**
     * This method redirect to HTTPS protocol from HTTP protocol
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     */
    public static void checkForHttpsProtocol(HttpServletRequest request, HttpServletResponse response){
        if (request.getHeader(X_FORWARDED_PROTO) != null) {
            if (request.getHeader(X_FORWARDED_PROTO).indexOf("https") != 0) {
                try {
                    response.sendRedirect("https://licencesmanager.herokuapp.com");
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static String readFrominputStram(InputStream inputStream) {
        String response = "";
        try {
            InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
            BufferedReader reader = new BufferedReader(inputStreamReader);
            String line = reader.readLine();
            while (line != null) {
                response = response.concat(line + "\n");
                line = reader.readLine();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return response;
    }

    public static void printInOut(OutputStream outputStream, String text) {
        try {
            outputStream.write(text.getBytes());
        } catch (IOException e) {
            e.printStackTrace();
        }
        try {
            outputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
