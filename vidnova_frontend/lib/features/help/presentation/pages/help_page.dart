import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Widget _section({
    required String title,
    required List<String> bullets,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: AppColors.textSecondary, height: 1.35)),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Довідка'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            const Text(
              '🌿 Вітаємо у Vidnova!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Vidnova — це твій персональний інструмент для підтримки ментального здоров'я, що базується на методах когнітивно-поведінкової терапії (КПТ). Програма допомагає відстежувати свій стан та працювати зі стресовими ситуаціями крок за кроком.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            _section(
              icon: Icons.calendar_month_outlined,
              title: '📅 Щоденний стан (Чек-ін)',
              bullets: const [
                'Опис дня: коротко зафіксуй, що відбулося.',
                'Емоції та інтенсивність: обери, що відчуваєш зараз, і оціни силу емоції від 0 до 100.',
                'Загальний стан: визнач свій рівень спокою на цей момент — це допоможе бачити динаміку з часом.',
              ],
            ),
            const SizedBox(height: 14),

            _section(
              icon: Icons.balance_outlined,
              title: '⚖️ Журнал ситуацій (Аналіз думок)',
              bullets: const [
                'Ситуація: опиши факт події — що саме сталося.',
                'Ловець думок: запиши автоматичні думки та оціни, наскільки сильно ти в них віриш.',
                'Аналіз (Терези): розділи докази на «ЗА» і «ПРОТИ».',
                'Новий погляд: сформулюй більш збалансовану думку, спираючись на факти «ПРОТИ».',
                'Результат: порівняй стан «До» та «Після», щоб побачити ефект переосмислення.',
              ],
            ),
            const SizedBox(height: 14),

            _section(
              icon: Icons.insights_outlined,
              title: '📊 Аналітика та прогрес',
              bullets: const [
                'Календар станів: кожен день зафарбовується у колір, що відображає самопочуття.',
                'Динаміка: графіки показують зміну середнього спокою та ефективність переосмислення.',
                'Частота емоцій: допомагає помічати, які емоції з’являються найчастіше.',
              ],
            ),
            const SizedBox(height: 14),

            _section(
              icon: Icons.auto_awesome_outlined,
              title: '🤖 Підтримка від AI',
              bullets: const [
                'На головній сторінці в картці «Сьогодні» може з’являтися коротка підтримуюча фраза, згенерована AI.',
                'AI використовує твій опис дня, домінуючу емоцію та рівень спокою, щоб сформулювати максимально просту й емпатичну підтримку.',
                'Це підказка для самодопомоги, а не діагноз і не заміна фахової допомоги.',
              ],
            ),
            const SizedBox(height: 14),

            _section(
              icon: Icons.lock_outline,
              title: '🔒 Конфіденційність',
              bullets: const [
                'Твій журнал — це твій безпечний простір для щирості з самим собою.',
                'Ми не показуємо твої записи іншим користувачам.',
              ],
            ),
            const SizedBox(height: 14),

            _section(
              icon: Icons.trending_up_outlined,
              title: '📈 Як досягти результату?',
              bullets: const [
                'Регулярність: навіть 5 хвилин на день мають значення — результат з’являється через повторення.',
                'Факти замість емоцій: записуй докази так, ніби їх знімала камера спостереження.',
                'Відстежуй прогрес: календар допоможе помітити, як зростає твоя здатність до самодопомоги.',
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Vidnova не замінює професійну психотерапію. Якщо тобі дуже важко — звернись по допомогу до фахівця або близьких.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
