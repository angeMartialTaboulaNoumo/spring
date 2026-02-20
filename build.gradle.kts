plugins {
	java
	id("org.springframework.boot") version "4.0.3"
	id("io.spring.dependency-management") version "1.1.7"
}

group = "tuto"
version = "0.0.1-SNAPSHOT"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(21)
	}
}

configurations {
	compileOnly {
		extendsFrom(configurations.annotationProcessor.get())
	}
}

repositories {
	mavenCentral()
}

dependencies {

	developmentOnly("org.springframework.boot:spring-boot-devtools")
	implementation("org.springframework.boot:spring-boot-starter-actuator")

	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("org.springframework.boot:spring-boot-starter-thymeleaf")

	implementation("jakarta.inject:jakarta.inject-api:2.0.1")

	compileOnly("org.projectlombok:lombok")
	annotationProcessor("org.projectlombok:lombok")

	implementation("org.springframework.boot:spring-boot-starter-validation")

//	implementation("org.springframework.boot:spring-boot-starter-data-jdbc")
//	runtimeOnly("org.postgresql:postgresql")

//	testImplementation("org.springframework.boot:spring-boot-starter-test")
//	testRuntimeOnly("org.junit.platform:junit-platform-launcher")

}

tasks.withType<JavaCompile> {
	options.compilerArgs.add("-parameters")
  options.encoding = "UTF-8"

}

tasks.withType<Javadoc>{
  options.encoding = "UTF-8"
}

tasks.withType<Test> {
	useJUnitPlatform()
}
