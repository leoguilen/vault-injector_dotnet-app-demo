FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build
WORKDIR /src
COPY ["VaultDemo.Api.csproj", "VaultDemo.Api.csproj"]
RUN dotnet restore "VaultDemo.Api.csproj"
COPY . .
RUN dotnet build "VaultDemo.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "VaultDemo.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "VaultDemo.Api.dll"]