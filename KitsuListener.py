import base64, json, platform
from os.path import join
from bs4 import BeautifulSoup
from robot.libraries.BuiltIn import BuiltIn
from ScreenCapLibrary import ScreenCapLibrary

class KitsuListener:
    ROBOT_LISTENER_API_VERSION = 2
    report = []
    suite_index = 0
    test_index = 0
    step_index = 0

    def start_suite(self, name, attrs):
        BuiltIn().set_log_level("TRACE")
        BuiltIn().import_library("ScreenCapLibrary")
        self.report.append({
            "name": name,
            "doc": attrs["doc"],
            "status": "NOT SET",
            "start_time": attrs["starttime"],
            "end_time": "",
            "elapsed_time": 0,
            "scenarios": []
        })

    def end_suite(self, name, attrs):
        self.report[self.suite_index]["status"] = attrs["status"]
        self.report[self.suite_index]["end_time"] = attrs["endtime"]
        self.report[self.suite_index]["elapsed_time"] = attrs["elapsedtime"]
        self.suite_index = self.suite_index + 1
        self.test_index = 0
        self.step_index = 0
        BuiltIn().set_log_level("NONE")

    def start_test(self, name, attrs):
        id = BuiltIn().get_variable_value("${TEST_NAME}")
        lib = BuiltIn().get_library_instance("ScreenCapLibrary")
        lib.start_video_recording(alias=id, fps=10, embed=False)

        self.report[self.suite_index]["scenarios"].append({
            "name": name,
            "doc": attrs["doc"],
            "tags": attrs["tags"],
            "line": attrs["lineno"],
            "status": "NOT SET",
            "start_time": attrs["starttime"],
            "end_time": "",
            "elapsed_time": 0,
            "steps": [],
            "video": ""
        })

    def end_test(self, name, attrs):
        id = BuiltIn().get_variable_value("${TEST_NAME}")
        lib = BuiltIn().get_library_instance("ScreenCapLibrary")
        output_video_file = lib.stop_video_recording(alias=id)
        
        with open(output_video_file, "rb") as video_file:
            b64_string = base64.b64encode(video_file.read())
            self.report[self.suite_index]["scenarios"][self.test_index]["video"] = "{}{}".format("data:video/webm;base64,", b64_string.decode("utf-8"))

        self.report[self.suite_index]["scenarios"][self.test_index]["status"] = attrs["status"]
        self.report[self.suite_index]["scenarios"][self.test_index]["end_time"] = attrs["endtime"]
        self.report[self.suite_index]["scenarios"][self.test_index]["elapsed_time"] = attrs["elapsedtime"]
        self.test_index = self.test_index + 1
        self.step_index = 0

    def start_keyword(self, name, attrs):
        self.report[self.suite_index]["scenarios"][self.test_index]["steps"].append({
            "name": attrs["kwname"],
            "doc": attrs["doc"],
            "type": attrs["type"],
            "line": attrs["lineno"],
            "status": "NOT SET",
            "start_time": attrs["starttime"],
            "end_time": "",
            "elapsed_time": 0,
            "library": attrs["libname"],
            "args": attrs["args"],
            "logs": []
        })

    def end_keyword(self, name, attrs):
        self.report[self.suite_index]["scenarios"][self.test_index]["steps"][self.step_index]["status"] = attrs["status"]
        self.report[self.suite_index]["scenarios"][self.test_index]["steps"][self.step_index]["end_time"] = attrs["endtime"]
        self.report[self.suite_index]["scenarios"][self.test_index]["steps"][self.step_index]["elapsed_time"] = attrs["elapsedtime"]
        self.step_index = self.step_index + 1

    def log_message(self, message):
        log_message = message["message"]
        log_level = message["level"]
        log_image = ""
        
        if (message["message"].__contains__("<img")):
            soup = BeautifulSoup(message["message"], "html.parser")
            image_src = soup.img.get("src")
            
            if (image_src.__contains__("data:image/png;base64,")):
                log_message = "Takes a screenshot of the current page and embeds it into a log file."
                log_image = image_src
            else:
                with open(join("results", image_src), "rb") as img_file:
                    b64_string = base64.b64encode(img_file.read())
                    log_message = "Takes a screenshot of the current page and embeds it into a log file."
                    log_image = "{}{}".format("data:image/png;base64,", b64_string.decode("utf-8"))
        
        self.report[self.suite_index]["scenarios"][self.test_index]["steps"][self.step_index]["logs"].append({
            "message": log_message,
            "image": log_image,
            "level": message["level"]
        })

    def close(self):
        self.suite_index = 0
        self.test_index = 0

        with open("info.json", "w") as write_info_file:
            json.dump({
                "env": "local",
                "username": platform.node(),
                "os_name": platform.system(),
                "python_version": platform.python_version()
            }, write_info_file, indent=4)

        with open("report.json", "w") as write_report_file:
            json.dump(self.report, write_report_file, indent=4)