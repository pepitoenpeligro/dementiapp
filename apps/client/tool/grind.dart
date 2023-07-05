import 'package:grinder/grinder.dart';

main(args) => grind(args);

// @Task()
// test() => new TestRunner().testAsync();

@Task()
runweb() {
  run("flutter",
      arguments: List<String>.of([
        "run",
        "-d",
        "chrome",
        "--no-sound-null-safety",
        "--web-renderer",
        "canvaskit"
      ]));
}

@Task()
clean() {
  log('🧹 Cleaning web Artifacts');
  try {
    run('flutter', arguments: ["clean"]);
  } catch (error) {
    log('Error cleaning existing artifacts: $error');
  }
}

@Task()
@Depends(clean)
buildWeb() {
  log('🛠️ Building web WebArtifact');
  try {
    run('flutter', arguments: [
      "build",
      "web",
      "--no-sound-null-safety",
      "--web-renderer",
      "canvaskit",
      "--release"
    ]);
  } catch (error) {
    log('Error building web artifact: $error');
  }
}

@Task()
@Depends(buildWeb)
compressWebWebArtifact() {
  log('📦 Zipping Web Artifact');
  try {
    run('zip',
        arguments: List<String>.of(["-r", "./location-web-app.zip", "./"]),
        workingDirectory: "build/web/");
  } catch (error) {
    log('Error zipping web artifact: $error');
  }
}

@Task()
@Depends(compressWebWebArtifact)
awsS3WebArtifactUpload() {
  log('⏫ Uploading Web Artifact to S3');
  try {
    run('aws',
        arguments: List<String>.of([
          "s3",
          "cp",
          "build/web/location-web-app.zip",
          "s3://location-web-app"
        ]));
  } catch (error) {
    log('Error uploading web artifact to S3: $error');
  }
}

@Task()
increment() {
  run('/bin/bash', arguments: [
    r"version=$( awk '/version:/ {print $2}' pubspec.yaml) && version=$(echo $version | perl -pe 's/^((\d+\.)*)(\d+)(.*)$/$1.($3+1).$4/e') "
  ]);
}

@Task()
@Depends(awsS3WebArtifactUpload)
release() {
  log('🚀 Releasing Web Artifact');
  try {
    run('aws',
        arguments: List<String>.of([
          "amplify",
          "start-deployment",
          "--app-id",
          "d32hkqu3lrja8t",
          "--branch-name",
          "dev1498",
          "--source-url",
          "s3://location-web-app/location-web-app.zip"
        ]));
  } catch (error) {
    log('Error deploying artifact to AWS Amplify: $error');
  }
}
