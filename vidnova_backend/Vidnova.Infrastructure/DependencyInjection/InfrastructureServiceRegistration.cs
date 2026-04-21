using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Infrastructure.Persistence;
using Vidnova.Infrastructure.Repositories;
using Vidnova.Infrastructure.Security;

namespace Vidnova.Infrastructure.DependencyInjection;

public static class InfrastructureServiceRegistration
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = $"Server={configuration["DB_SERVER"]},{configuration["DB_PORT"]};" +
                               $"Database={configuration["DB_NAME"]};" +
                               $"User Id={configuration["DB_USER"]};" +
                               $"Password={configuration["DB_PASSWORD"]};" +
                               "TrustServerCertificate=True;Encrypt=False;MultipleActiveResultSets=True;";
        
        services.AddDbContext<AppDbContext>(options => 
            options.UseSqlServer(connectionString,
                b => b.MigrationsAssembly(typeof(AppDbContext).Assembly.FullName)));

        services.AddScoped<IUnitOfWork, EfUnitOfWork>();

        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IDailyCheckInRepository, DailyCheckInRepository>();
        services.AddScoped<IDailyCheckInAiInsightRepository, DailyCheckInAiInsightRepository>();
        services.AddScoped<IAbcEntryRepository, AbcEntryRepository>();
        
        services.Configure<JwtOptions>(configuration.GetSection("Jwt"));
        services.AddScoped<IPasswordHasher, BCryptPasswordHasher>();
        services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();
        
        services.Configure<GoogleAuthOptions>(configuration.GetSection("GoogleAuth"));
        services.AddScoped<IGoogleIdTokenValidator, GoogleIdTokenValidator>();

        services.Configure<Vidnova.Infrastructure.AI.GeminiOptions>(configuration.GetSection("Gemini"));
        services.AddHttpClient<ITextGenerationService, Vidnova.Infrastructure.AI.GeminiTextGenerationService>(client =>
        {
            // BaseUrl can be overridden by config; default points to Google Gemini REST API host.
            var baseUrl = configuration["Gemini:BaseUrl"];
            client.BaseAddress = new Uri(string.IsNullOrWhiteSpace(baseUrl)
                ? "https://generativelanguage.googleapis.com"
                : baseUrl);
            client.Timeout = TimeSpan.FromSeconds(60);
        });

        return services;
    }
}