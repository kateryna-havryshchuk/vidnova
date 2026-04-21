using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Vidnova.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddDailyCheckIns : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DailyCheckIns",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Date = table.Column<DateOnly>(type: "date", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1500)", maxLength: 1500, nullable: false),
                    CalmScore = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DailyCheckIns", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "DailyCheckInEmotions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    DailyCheckInId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Emotion = table.Column<int>(type: "int", nullable: false),
                    Intensity = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DailyCheckInEmotions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DailyCheckInEmotions_DailyCheckIns_DailyCheckInId",
                        column: x => x.DailyCheckInId,
                        principalTable: "DailyCheckIns",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_DailyCheckInEmotions_DailyCheckInId",
                table: "DailyCheckInEmotions",
                column: "DailyCheckInId");

            migrationBuilder.CreateIndex(
                name: "IX_DailyCheckIns_UserId_Date",
                table: "DailyCheckIns",
                columns: new[] { "UserId", "Date" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DailyCheckInEmotions");

            migrationBuilder.DropTable(
                name: "DailyCheckIns");
        }
    }
}
