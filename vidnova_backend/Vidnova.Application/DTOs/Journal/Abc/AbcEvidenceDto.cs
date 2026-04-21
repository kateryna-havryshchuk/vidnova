namespace Vidnova.Application.DTOs.Journal.Abc;

public sealed record AbcEvidenceDto(
    Guid Id,
    string Text,
    bool IsFor
);