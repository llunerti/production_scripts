import FWCore.ParameterSet.Config as cms

from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunes2017.PythiaCP5Settings_cfi import *
from GeneratorInterface.EvtGenInterface.EvtGenSetting_cff import *

generator = cms.EDFilter(
    "Pythia8GeneratorFilter",
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    maxEventsToPrint = cms.untracked.int32(0),
    pythiaPylistVerbosity = cms.untracked.int32(0),
    comEnergy = cms.double(13000.0),
    ExternalDecays = cms.PSet(
        EvtGen130 = cms.untracked.PSet(
            decay_table = cms.string('GeneratorInterface/EvtGenInterface/data/DECAY_2014_NOLONGLIFE.DEC'),
            particle_property_file = cms.FileInPath('GeneratorInterface/EvtGenInterface/data/evt_2014.pdl'),
            list_forced_decays = cms.vstring('MyD_s+','MyD_s-','MyPhi'),
            operates_on_particles = cms.vint32(),
            convertPythiaCodes = cms.untracked.bool(False),
            user_decay_embedded = cms.vstring(
"""
Alias      MyD_s+      D_s+
Alias      MyD_s-      D_s-
Alias      MyPhi       phi
ChargeConj MyD_s+ MyD_s-
ChargeConj MyPhi MyPhi

Decay MyD_s+
1.000      MyPhi  pi+     SVS;
Enddecay
CDecay MyD_s-

Decay MyPhi
1.0000     K+   K-      VSS;
Enddecay

End
"""
            )
        ),
        parameterSets = cms.vstring('EvtGen130')
    ),
    PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        processParameters = cms.vstring(
            "SoftQCD:nonDiffractive = on",
            'PTFilter:filter = on', # this turn on the filter
            'PTFilter:quarkToFilter = 4', # PDG id of q quark
            'PTFilter:scaleToFilter = 1.0'),
        parameterSets = cms.vstring(
            'pythia8CommonSettings',
            'pythia8CP5Settings',
            'processParameters',
        )
    )
)

generator.PythiaParameters.processParameters.extend(EvtGenExtraParticles)

#Filter only Ds
dfilter = cms.EDFilter(
    "PythiaFilter",
    MinPt = cms.untracked.double(0.3),
    ParticleID = cms.untracked.int32(431)
)

#Filter Phi->KK
phidecayfilter = cms.EDFilter(
    "PythiaDauVFilter",
    verbose         = cms.untracked.int32(1),
    NumberDaughters = cms.untracked.int32(2),
    MotherID        = cms.untracked.int32(431),
    ParticleID      = cms.untracked.int32(333),
    DaughterIDs     = cms.untracked.vint32(321,-321),
    MinPt           = cms.untracked.vdouble( 0.8,  0.8),
    MinEta          = cms.untracked.vdouble(-2.5, -2.5),
    MaxEta          = cms.untracked.vdouble( 2.5,  2.5)
)

ProductionFilterSequence = cms.Sequence(generator*phidecayfilter*dfilter)
