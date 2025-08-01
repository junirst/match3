using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Index("ChapterId", "LevelNumber", Name = "UQ__Levels__C4A1B5D4E24944EA", IsUnique = true)]
public partial class Level
{
    [Key]
    [Column("LevelID")]
    public int LevelId { get; set; }

    [Column("ChapterID")]
    public int ChapterId { get; set; }

    public int LevelNumber { get; set; }

    [StringLength(100)]
    public string? LevelName { get; set; }

    [StringLength(50)]
    public string? EnemyType { get; set; }

    public int? EnemyMaxHealth { get; set; }

    public int? RequiredLevel { get; set; }

    public bool? IsUnlocked { get; set; }

    public DateTime? CreatedDate { get; set; }

    [ForeignKey("ChapterId")]
    [InverseProperty("Levels")]
    public virtual Chapter Chapter { get; set; } = null!;
}
