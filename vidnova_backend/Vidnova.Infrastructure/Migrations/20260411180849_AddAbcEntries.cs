using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Vidnova.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddAbcEntries : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AbcEntries",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Situation = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    AutomaticThought = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    ThoughtBelief = table.Column<int>(type: "int", nullable: false),
                    AlternativeThought = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    AlternativeThoughtBelief = table.Column<int>(type: "int", nullable: false),
                    FinalEmotionIntensity = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AbcEntries", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AbcEntryEmotions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    AbcEntryId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Emotion = table.Column<int>(type: "int", nullable: false),
                    InitialIntensity = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AbcEntryEmotions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AbcEntryEmotions_AbcEntries_AbcEntryId",
                        column: x => x.AbcEntryId,
                        principalTable: "AbcEntries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AbcEvidence",
                columns: table => new
                {
                    AbcEntryId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    IsFor = table.Column<bool>(type: "bit", nullable: false),
                    Text = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AbcEvidence", x => x.AbcEntryId);
                    table.ForeignKey(
                        name: "FK_AbcEvidence_AbcEntries_AbcEntryId",
                        column: x => x.AbcEntryId,
                        principalTable: "AbcEntries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AbcEntries_UserId_CreatedDate",
                table: "AbcEntries",
                columns: new[] { "UserId", "CreatedDate" });

            migrationBuilder.CreateIndex(
                name: "IX_AbcEntryEmotions_AbcEntryId",
                table: "AbcEntryEmotions",
                column: "AbcEntryId");

            migrationBuilder.CreateIndex(
                name: "IX_AbcEvidence_AbcEntryId",
                table: "AbcEvidence",
                column: "AbcEntryId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AbcEntryEmotions");

            migrationBuilder.DropTable(
                name: "AbcEvidence");

            migrationBuilder.DropTable(
                name: "AbcEntries");
        }
    }
}
