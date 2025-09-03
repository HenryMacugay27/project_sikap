import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_sikap/model/exam_result.dart';
import '../../../../model/user.dart';
import '../../../../utils/dml/dml_statement.dart' as dml;

class StudentGraphScreen extends StatefulWidget {
  final User student;
  final User teacher;

  const StudentGraphScreen({super.key, required this.student, required this.teacher});

  @override
  State<StudentGraphScreen> createState() => _StudentGraphScreenState();
}

class _StudentGraphScreenState extends State<StudentGraphScreen> {
  List<ExamResult> examResults = [];

  @override
  void initState() {
    super.initState();
    _fetchExamResults(student: widget.student);
  }

  Future<void> _fetchExamResults({required User student}) async {
    try {
      final results = await dml.DmlStatement().fetchExamResults(student);
      setState(() {
        examResults = results;
      });
    } catch (e) {
      //print('Error fetching exam results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade100,
          title: Text(
            '${widget.student.firstName} - ${widget.teacher.firstName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pre-Exam'),
              Tab(text: 'Exam'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PreExamChartTabs(examResults: examResults),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChartWidget1(dataType: 'Post_Exam', examResults: examResults),
            ),
          ],
        ),
      ),
    );
  }
}

class PreExamChartTabs extends StatelessWidget {
  final List<ExamResult> examResults;

  const PreExamChartTabs({super.key, required this.examResults});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(text: 'Easy'),
              Tab(text: 'Average'),
              Tab(text: 'Difficult'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: [
                LineChartWidget(dataType: 'Easy', examResults: examResults),
                LineChartWidget(dataType: 'Average', examResults: examResults),
                LineChartWidget(dataType: 'Difficult', examResults: examResults),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final String dataType;
  final List<ExamResult> examResults;

  const LineChartWidget({super.key, required this.dataType, required this.examResults});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    List<ExamResult> filteredResults = [];

    double index = 1.0;
    for (var result in examResults) {
      if (result.examType == dataType) {
        spots.add(FlSpot(index, result.score.toDouble()));
        filteredResults.add(result);
        index++;
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Over Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.indigo.shade50,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1, // Adjust this value to increase spacing between left titles
                      reservedSize: 20, // Increase the reserved space for left titles
                      getTitlesWidget: (value, meta) {
                        // Remove decimal .0 and show the value as an integer
                        return Text(
                          value.toInt().toString(), // Convert value to int to remove decimal
                          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1, // Adjust this value to increase spacing between left titles
                      reservedSize: 20, // Increase the reserved space for left titles
                      getTitlesWidget: (value, meta) {
                        // Remove decimal .0 and show the value as an integer
                        return Text(
                          value.toInt().toString(), // Convert value to int to remove decimal
                          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.indigo.shade200)),
                minX: 1,
                maxX: index - 1,
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: true, color: Colors.indigo.shade100),
                    dotData: FlDotData(show: true),
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Exam Results Table',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateColor.resolveWith((states) => Colors.indigo.shade100),
              dataRowColor: WidgetStateColor.resolveWith((states) => Colors.white),
              columns: const [
                DataColumn(label: Text('Exam Title')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Date Taken')),
                DataColumn(label: Text('Grade Level')),
              ],
              rows: filteredResults.map((result) {
                return DataRow(cells: [
                  DataCell(Text(result.examType)),
                  DataCell(Text('${result.score}')),
                  DataCell(Text(result.dateCreated.toLocal().toString().split(' ')[0])),
                  DataCell(Text('${result.gradeLevel}')),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class LineChartWidget1 extends StatelessWidget {
  final String dataType;
  final List<ExamResult> examResults;

  const LineChartWidget1({super.key, required this.dataType, required this.examResults});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    List<ExamResult> filteredResults = [];

    double index = 1.0;
    for (var result in examResults) {
      if (result.examType == dataType) {
        spots.add(FlSpot(index, result.score.toDouble()));
        filteredResults.add(result);
        index++;
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Over Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.indigo.shade50,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 4, // Adjust this value to increase spacing between left titles
                      reservedSize: 20, // Increase the reserved space for left titles
                      getTitlesWidget: (value, meta) {
                        // Remove decimal .0 and show the value as an integer
                        return Text(
                          value.toInt().toString(), // Convert value to int to remove decimal
                          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.indigo.shade200)),
                minX: 1,
                maxX: index - 1,
                minY: 0,
                maxY: 20,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: true, color: Colors.indigo.shade100),
                    dotData: FlDotData(show: true),
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Exam Results Table',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateColor.resolveWith((states) => Colors.indigo.shade100),
              dataRowColor: WidgetStateColor.resolveWith((states) => Colors.white),
              columns: const [
                DataColumn(label: Text('Exam Title')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Date Taken')),
                DataColumn(label: Text('Grade Level')),
              ],
              rows: filteredResults.map((result) {
                return DataRow(cells: [
                  DataCell(Text(result.examType)),
                  DataCell(Text('${result.score}')),
                  DataCell(Text(result.dateCreated.toLocal().toString().split(' ')[0])),
                  DataCell(Text('${result.gradeLevel}')),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final List<ExamResult> examResults;

  const BarChartWidget({super.key, required this.examResults});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];

    for (var result in examResults) {
      barGroups.add(
        BarChartGroupData(
          x: result.gradeLevel,
          barRods: [
            BarChartRodData(
              toY: result.score.toDouble(),
              color: Colors.orangeAccent,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exam Scores by Grade Level',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 5,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('G${value.toInt()}');
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }
}
