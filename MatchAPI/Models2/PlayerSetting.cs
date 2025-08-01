using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

public partial class PlayerSetting
{
    [Key]
    [Column("SettingID")]
    public int SettingId { get; set; }

    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [Column("BGMEnabled")]
    public bool? Bgmenabled { get; set; }

    [Column("SFXEnabled")]
    public bool? Sfxenabled { get; set; }

    [Column("BGMVolume")]
    public double? Bgmvolume { get; set; }

    [Column("SFXVolume")]
    public double? Sfxvolume { get; set; }

    [StringLength(20)]
    public string? Language { get; set; }

    public bool? FirstLaunch { get; set; }

    public DateTime? UpdatedDate { get; set; }

    [ForeignKey("PlayerId")]
    [InverseProperty("PlayerSettings")]
    public virtual Player Player { get; set; } = null!;
}
