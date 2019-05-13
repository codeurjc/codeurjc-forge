package es.codeurjc.test.sonarqube;

import java.net.MalformedURLException;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import java.io.PrintWriter;
import java.io.File;
import java.io.FileNotFoundException;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;

import io.github.bonigarcia.wdm.ChromeDriverManager;

public class SonarQubeConfTest {

	private static String sutURL;

	WebDriver driver;

	@BeforeClass
	public static void setupClass() {
	
		sutURL = "http://" + System.getenv("APP_URL") + ":9000/sessions/new";
		System.out.println("App url: " + sutURL);
		ChromeDriverManager.chromedriver().setup();
	}

	@Before
	public void setupTest() throws MalformedURLException {
		driver = new ChromeDriver();
	}

	@After
	public void teardown() {
		if (driver != null) {
			driver.quit();
		}
	}

	@Test
	public void createTest() throws InterruptedException {

		driver.get(sutURL);
		String token = "";
		String newPassword = System.getenv("ADMIN_PWD");
		File file = new File("/workdir/SonarQubeToken.txt");
        PrintWriter printWriter = null;

		Thread.sleep(2000);

		driver.findElement(By.id("login")).click();
		driver.findElement(By.id("login")).sendKeys("admin");

		driver.findElement(By.id("password")).click();
		driver.findElement(By.id("password")).sendKeys("admin");

		driver.findElement(By.name("commit")).click();

		Thread.sleep(2000);

		// Give a name for the token
		driver.findElement(By.className("input-large")).sendKeys("Jenkins");
		Thread.sleep(1000);
		driver.findElement(By.xpath("//button[text()=\"Generate\"]")).click();
		
		Thread.sleep(2000);

		token = driver.findElement(By.className("spacer-right")).getText();
		
		driver.findElement(By.className("js-skip")).click();
		
		try {
			printWriter = new PrintWriter(file);
			printWriter.println(token);
			printWriter.close();
        } catch (FileNotFoundException e) {
			e.printStackTrace();
        }
		
		sutURL = "http://" + System.getenv("APP_URL") + ":9000/account/security";
		driver.get(sutURL);
		
		Thread.sleep(2000);
		
		driver.findElement(By.id("old_password")).click();
		driver.findElement(By.id("old_password")).sendKeys("admin");
		driver.findElement(By.id("password")).click();
		driver.findElement(By.id("password")).sendKeys(newPassword);
		driver.findElement(By.id("password_confirmation")).click();
		driver.findElement(By.id("password_confirmation")).sendKeys(newPassword);
		driver.findElement(By.id("change-password")).click();
		
		Thread.sleep(2000);
		
	}

}
